classdef LineH < handle
    properties (Dependent=true,SetObservable=true)
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
            addlistener(obj,["Position","PrimaryColor","Width","Dashed"],'PostSet',@obj.updateBuffer);
            %addlistener(obj,'YData','PostSet',@obj.updateBuffer);
        end
        
        function position = get.Position(obj)
            position = [obj.gLine.x,obj.gLine.y];
        end
        
        function set.Position(obj,position)
            s1 = size(position);
            s2 = size(obj.gLine.x);
            
            if (s1(1) == s2(1))
                obj.gLine.x = position(:,1);
                obj.gLine.y = position(:,2);
            else
                x = position(:,1);
                y = position(:,2);
                c = obj.gLine.primaryColor;
                w = obj.gLine.width;
                d = obj.gLine.dashed;
                newLine = GeomatPlot.Draw.gLine( single(x), single(y), single(c), single(w), d);
                obj.plot.removeDrawable(obj.gLine);
                obj.gLine = newLine;
                obj.plot.addDrawable(obj.gLine);
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
        end

        function width = get.Width(obj)
            width = obj.gLine.width;
        end

        function set.Width(obj, width)
            obj.gLine.width = width;
        end

        function dashed = get.Dashed(obj)
            dashed = obj.gLine.dashed;
        end

        function set.Dashed(obj, dashed)
            obj.gLine.dashed = dashed;
        end

        function updateBuffer(obj,~,~)
            notify(obj,'Moved');
            obj.plot.updateDrawable(obj.gLine);
        end
    end
end

