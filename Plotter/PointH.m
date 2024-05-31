classdef PointH < handle
    properties (Dependent=true)
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

    properties(Access=protected)
        gPointH
    end

    events
        Moved
    end
    
    methods
        function obj = PointH(plot,p,color,size,type,movable)
            obj.gPoint = GeomatPlot.Draw.gPoint(p(1),p(2), color, size,type,movable);
            addDrawable(plot,obj.gPoint);
            obj.plot = plot;
            if movable
                obj.gPointH = handle(obj.gPoint,'CallbackProperties');
                set(obj.gPointH,'MovementCallback',@(~,~)notify(obj,'Moved'));
            end
            addFig(obj.plot,obj);
        end
        
        function delete(obj)
            if obj.gPoint.isMovable
                set(obj.gPointH,'MovementCallback',[]);
                obj.gPointH = [];
            end
            obj.gPoint = [];
            obj.UserData = [];
        end
        
        function position = get.Position(obj)
            position = [obj.gPoint.x , obj.gPoint.y];
        end
        
        function set.Position(obj,position)
            obj.gPoint.x = position(1);
            obj.gPoint.y = position(2);
            updateDrawable(obj.plot, obj.gPoint);
        end
        
        function color = get.PrimaryColor(obj)
            color = obj.gPoint.primaryColor;
        end
        
        function set.PrimaryColor(obj,color)
            obj.gPoint.primaryColor = color;
            updateDrawable(obj.plot, obj.gPoint);
        end
        
        function width = get.Width(obj)
            width = obj.gPoint.width;
        end
        
        function set.Width(obj,width)
            obj.gPoint.width = width;
            updateDrawable(obj.plot, obj.gPoint);
        end
        
        function type = get.Type(obj)
            type = obj.gPoint.type;
        end
        
        function set.Type(obj,type)
            obj.gPoint.type = type;
            updateDrawable(obj.plot, obj.gPoint);
        end
        
    end
end

