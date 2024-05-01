classdef PointH < handle
    properties (Dependent=true,SetObservable=true)
        Position,
        PrimaryColor,
        Width,
        Type
    end

    properties
        gPoint
        plot Plot
        UserData
    end

    events
        Moved
    end
    
    methods
        function obj = PointH(gPoint,plot)
            obj.gPoint = gPoint;
            obj.plot = plot;
            addlistener(obj,["Position","PrimaryColor","Width","Type"],'PostSet',@obj.updateBuffer);
            gPointH = handle(obj.gPoint,'CallbackProperties');
            set(gPointH,'MovementCallback',@(~,~)notify(obj,'Moved'));
        end
        
        function updateBuffer(obj,~,~)
            notify(obj,'Moved');
            obj.plot.updateDrawable(obj.gPoint);
        end

        function position = get.Position(obj)
            position = [obj.gPoint.x , obj.gPoint.y];
        end
        
        function set.Position(obj,position)
            obj.gPoint.x = position(1);
            obj.gPoint.y = position(2);
        end

        function color = get.PrimaryColor(obj)
            color = obj.gPoint.primaryColor;
        end

        function set.PrimaryColor(obj,color)
            obj.gPoint.primaryColor = color;
        end

        function width = get.Width(obj)
            width = obj.gPoint.primaryColor;
        end

        function set.Width(obj,width)
            obj.gPoint.width = width;
        end
        
        function type = get.Type(obj)
            type = obj.gPoint.type;
        end

        function set.Type(obj,type)
            obj.gPoint.type = type;
        end

    end
end

