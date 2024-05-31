classdef PatchH < handle
    
    properties(Dependent)
        Position
    end
    
    properties
        gPatch
        plot Plot
        UserData
    end

    properties(Access=protected)
        gPatchH
        Movable
        position
    end

    events
        Moved
    end
    
    methods
        function obj = PatchH(plot,x,y,pc,bc,fa,mo)
            [x, y, indices, ~] = calcDeluany(x,y);
            obj.gPatch = GeomatPlot.Draw.gPatch(x,y, indices-1, pc, bc, fa,mo);
            obj.plot = plot;
            addDrawable(obj.plot,obj.gPatch);
            obj.position = [x,y];
            obj.Movable = mo;
            if mo
                obj.gPatchH = handle(obj.gPatch,'CallbackProperties');
                set(obj.gPatchH,'MovementCallback',@(~,~)notify(obj,'Moved'));
            end
            addFig(obj.plot,obj);
        end

        function delete(obj)
            if obj.Movable
                set(obj.gPatchH,'MovementCallback',[]);
                obj.gPatchH = [];
            end
            obj.gPatch = [];
            obj.UserData = [];
        end

        function position = get.Position(obj)
            position = obj.Position;
        end

        function set.Position(obj, position)
            obj.position = position;
            patch = obj.gPatch;
            patchXSize = size(patch.x,1);

            if patchXSize == size(position,1)
                if ~any(triangleAreas(position,patch.indices+1) <= 0)
                    patch.x = position(:,1);
                    patch.y = position(:,2);
                    updateDrawable(obj.plot,obj.gPatch);
                    return;
                end
            end

            [x, y, indices, ~] = calcDeluany(position(:,1),position(:,2));
            if patchXSize == size(x,1) && size(patch.indices,1) == size(indices,1)
                patch.x = x;
                patch.y = y;
                patch.indices = indices-1;
                updateDrawable(obj.plot,obj.gPatch);
            else
                newPatch = GeomatPlot.Draw.gPatch(x,y, indices-1, patch.primaryColors, patch.borderColors, patch.faceAlpha,patch.isMovable);
                addDrawable(obj.plot,newPatch);
                removeDrawable(obj.plot,patch);
                if obj.Movable
                    set(obj.gPatchH,'MovementCallback',[]);
                    obj.gPatchH = handle(newPatch,'CallbackProperties');
                    set(obj.gPatchH,'MovementCallback',@(~,~)notify(obj,'Moved'));
                end
                obj.gPatch = newPatch;
            end
        end
    end
end

