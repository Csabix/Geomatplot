classdef LineH < handle
    properties (Dependent=true)
        Position,
        PrimaryColor,
        Width,
        Dashed
    end

    properties
        gLine
        plot Plot
        UserData
    end

    events
        Moved
    end
    
    methods
        function obj = LineH(gLine,plot)
            obj.gLine = gLine;
            obj.plot = plot;
            addDrawable(plot,gLine);
            addFig(plot,obj);
        end

        function delete(obj)
            obj.gLine = [];
            obj.UserData = [];
        end
        
        function position = get.Position(obj)
            position = [obj.gLine.x,obj.gLine.y];
        end

        function set.Position(obj,position)
            if size(position,1) == size(obj.gLine.x,1)
                obj.gLine.x = position(:,1);
                obj.gLine.y = position(:,2);
                updateDrawable(obj.plot,obj.gLine);
            else
                x = position(:,1);
                y = position(:,2);
                newLine = GeomatPlot.Draw.gLine( single(x), single(y), obj.gLine.primaryColor, obj.gLine.width, obj.gLine.dashed);
                addDrawable(obj.plot,newLine);
                removeDrawable(obj.plot,obj.gLine);
                obj.gLine = newLine;
            end
        end

        function primaryColor = get.PrimaryColor(obj)
            primaryColor = obj.gLine.primaryColor;
        end

        function set.PrimaryColor(obj, primaryColor)
            if ~isnumeric(primaryColor)
                primaryColor = parseColor(primaryColor);
            end
            obj.gLine.primaryColor = primaryColor;
            updateDrawable(obj.plot,obj.gLine);
        end

        function width = get.Width(obj)
            width = obj.gLine.width;
        end

        function set.Width(obj, width)
            obj.gLine.width = width;
            updateDrawable(obj.plot,obj.gLine);
        end

        function dashed = get.Dashed(obj)
            dashed = obj.gLine.dashed;
        end

        function set.Dashed(obj, dashed)
            obj.gLine.dashed = dashed;
            updateDrawable(obj.plot,obj.gLine);
        end
    end
end

