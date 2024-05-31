classdef PolygonH < handle
    properties (Dependent=true,SetObservable=true)
        Position
    end
    
    properties
        gPolygon
        plot Plot
        UserData
    end

    properties(Access=protected)
        lastX
        lastY
        Movable
        gPolygonH
    end

    events
        Moved
    end
    
    methods
        function obj = PolygonH(plot,x,y,pc,bc,fa,mo)
            [x, y, indices, ~] = calcDeluany(x,y);
            obj.gPolygon = GeomatPlot.Draw.gPolygon(x,y, indices-1, pc, bc, fa,mo);
            obj.lastX = x;
            obj.lastY = y;

            obj.plot = plot;
            addDrawable(obj.plot,obj.gPolygon);
            
            obj.Movable = mo;
            if mo
                obj.gPolygonH = handle(obj.gPolygon,'CallbackProperties');
                set(obj.gPolygonH,'MovementCallback',@obj.MovementCallback);
            end
            addFig(obj.plot,obj);
        end

        function delete(obj)
            if obj.Movable
                set(obj.gPolygonH,'MovementCallback',[]);
                obj.gPolygonH = [];
            end
            obj.gPolygon = [];
            obj.UserData = [];
        end
        
        function x = get.Position(obj)
            x = [obj.lastX, obj.lastY];
        end
        
        function set.Position(obj,position)
            x = position(:,1);
            y = position(:,2);
            sizeX = size(obj.gPolygon.x,1);
            if (size(position,1) == sizeX)
                indices = obj.gPolygon.indices;
                if any(triangleAreas(position, indices) < 0)
                    [x,y,indices] = calcDeluany(x,y);
                    if size(x,1) == sizeX
                        obj.gPolygon.x = x;
                        obj.gPolygon.y = y;
                        obj.gPolygon.indices = indices - 1;
                        updateDrawable(obj.plot,obj.gPolygon);
                    else
                        newSizePolygon(obj,x,y,indices);
                    end
                else
                    obj.gPolygon.x = x;
                    obj.gPolygon.y = y;
                    obj.lastX = x;
                    obj.lastY = y;
                    updateDrawable(obj.plot,obj.gPolygon);
                end
            else
                [x,y,indices] = calcDeluany(x,y);
                newSizePolygon(obj,x,y,indices);
            end
            obj.lastX = x;
            obj.lastY = y;
        end

        function MovementCallback(obj,~,~)
            position = [obj.gPolygon.x, obj.gPolygon.y];
            indices = obj.gPolygon.indices + 1;
            currentCount = size(position,1);
            if any(triangleAreas(position, indices) < 0)
                [x,y,indices] = calcDeluany(obj.gPolygon.x,obj.gPolygon.y);
                if size(x,1) == currentCount
                    obj.gPolygon.x = x;
                    obj.gPolygon.y = y;
                    obj.gPolygon.indices = indices - 1;
                    updateDrawable(obj.plot,obj.gPolygon);
                    obj.lastX = x;
                    obj.lastY = y;
                else
                    obj.gPolygon.x = obj.lastX;
                    obj.gPolygon.y = obj.lastY;
                    updateDrawable(obj.plot,obj.gPolygon);
                end
            else
                obj.lastX = position(:,1);
                obj.lastY = position(:,2);
            end
            
            notify(obj,'Moved');
        end

        function newSizePolygon(obj,x,y,indices)
            newPolygon = GeomatPlot.Draw.gPolygon(x,y, indices-1, obj.gPolygon.primaryColors, obj.gPolygon.borderColors, obj.gPolygon.faceAlpha,obj.Movable);
            addDrawable(obj.plot,newPolygon);
            if obj.Movable
                set(obj.gPolygonH,'MovementCallback',[]);
                obj.gPolygonH = handle(newPolygon,'CallbackProperties');
                set(obj.gPolygonH,'MovementCallback',@obj.MovementCallback);
            end
            removeDrawable(obj.plot,obj.gPolygon);
            obj.gPolygon = newPolygon;
        end
    end
end