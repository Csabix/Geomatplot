classdef ImageH < handle
    properties
        gImage
        plot Plot
        UserData
    end

    properties(Dependent)
        Position,
        Size,
        Visible
    end

    events
        Moved
    end
    
    methods
        function obj = ImageH(plot, location, x, y, w)
            obj.gImage = GeomatPlot.Draw.gImage(location, x, y, w);
            obj.plot = plot;
            addDrawable(obj.plot,obj.gImage);
            addFig(obj.plot,obj);
        end

        function delete(obj)
            obj.gImage = [];
            obj.UserData = [];
        end

        function position = get.Position(obj)
            position = [obj.gImage.x,obj.gImage.y];
        end

        function size = get.Size(obj)
            size = [obj.gImage.w,obj.gImage.h];
        end

        function visible = get.Visible(obj)
            visible = obj.gImage.getID ~= -1;
        end

        function set.Position(obj, position)
            arguments
                obj ImageH
                position (1,2)
            end
            obj.gImage.x = position(1);
            obj.gImage.y = position(2);
        end

        function set.Size(obj, size)
            arguments
                obj ImageH
                size (1,2)
            end
            obj.gImage.w = size(1);
            obj.gImage.h = size(2);
        end

        function set.Visible(obj, visible)
            if visible
                addDrawable(obj.plot,obj.gImage);
            else
                removeDrawable(obj.plot,obj.gImage);
            end
        end

        function enforceAspect(obj)
            enforceAspect(obj.gImage);
        end
    end
end

