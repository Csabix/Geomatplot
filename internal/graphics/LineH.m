classdef LineH < handle
    properties (Dependent=true,SetObservable=true)
        XData
        YData
    end

    properties
        gLine
        plot
        UserData
    end

    events
        Moved
    end
    
    methods
        function obj = LineH(gLine,plot)
            obj.gLine = gLine;
            obj.plot = plot;
            addlistener(obj,'XData','PostSet',@obj.updateBuffer);
            addlistener(obj,'YData','PostSet',@obj.updateBuffer);
        end
        
        function x = get.XData(obj)
            x = obj.gLine.x;
        end
        
        function set.XData(obj,x)
            obj.gLine.x = x;
        end

        function y = get.YData(obj)
            y = obj.gLine.y;
        end
        
        function set.YData(obj,y)
            obj.gLine.y = y;
        end

        function updateBuffer(obj,~,~)
            notify(obj,'Moved');
            obj.plot.updateDrawable(obj.gLine);
        end
    end
end

