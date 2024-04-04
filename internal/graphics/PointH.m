classdef PointH < handle
    properties (Dependent=true,SetObservable=true)
        Position
    end

    properties
        gPoint
        plot
        UserData
    end

    events
        Moved
    end
    
    methods
        function obj = PointH(gPoint,plot)
            obj.gPoint = gPoint;
            obj.plot = plot;
            addlistener(obj,'Position','PostSet',@obj.updateBuffer);
            gPointH = handle(obj.gPoint,'CallbackProperties');
            set(gPointH,'MovingPointCallback',@(~,~)notify(obj,'Moved'));
        end
        
        function position = get.Position(obj)
            position = [obj.gPoint.x , obj.gPoint.y];
        end
        
        function set.Position(obj,position)
            obj.gPoint.x = position(1);
            obj.gPoint.y = position(2);
        end

        function updateBuffer(obj,~,~)
            notify(obj,'Moved');
            obj.plot.updateDrawable(obj.gPoint);
        end
    end
end

