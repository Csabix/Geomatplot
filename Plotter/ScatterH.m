classdef ScatterH < handle
    properties (Dependent=true,SetObservable=true)
        Position
    end
    
    properties (SetObservable=true)
        PrimaryColor,
        Width
    end

    properties
        gPoints
        Visible
        plot Plot
        UserData
    end

    properties(Access=private)
        position
    end

    events
        Moved
    end
    
    methods
        function obj = ScatterH(position,plot,color,width,visible)
            obj.Visible = visible;
            obj.gPoints = [];

            obj.plot = plot;
            obj.Width = width;
            obj.PrimaryColor = color;
            obj.position = [];
            obj.Position = position;
        end

        function set.Visible(obj,visible)
            if visible
                addDrawables(obj.plot,obj.gPoints);
            else
                removeDrawables(obj.plot,obj.gPoints);
            end
            obj.Visible = visible;
        end

        function position = get.Position(obj)
            position = obj.position;
        end
        
        function set.Position(obj,position)
            oldCount = size(obj.position,1);
            currentCount = size(position,1);

            obj.position = position;

            if obj.Visible
                if oldCount == currentCount
                    for i = 1:currentCount
                        currentPoint = obj.gPoints(i);
                        currentPoint.x = position(i,1);
                        currentPoint.y = position(i,2);
                    end
                    updateDrawables(obj.plot,obj.gPoints);
                    
                elseif oldCount > currentCount
                    for i = 1:currentCount
                        currentPoint = obj.gPoints(i);
                        currentPoint.x = position(i,1);
                        currentPoint.y = position(i,2);
                    end
                    toRemove = obj.gPoints(currentCount+1:end);
                    obj.gPoints = obj.gPoints(1:currentCount);
                    
                    removeDrawables(obj.plot,toRemove);
                    updateDrawables(obj.plot,obj.gPoints);
                else
                    for i = 1:oldCount
                        currentPoint = obj.gPoints(i);
                        currentPoint.x = position(i,1);
                        currentPoint.y = position(i,2);
                    end

                    newPoints = repmat(java.lang.Object,currentCount - oldCount,1);
                    ind = 1;
                    c = obj.PrimaryColor;
                    w = obj.Width;
                    for i = (oldCount+1):currentCount
                        newPoints(ind) = GeomatPlot.Draw.gPoint(position(i,1),position(i,2), c, w,0,false);
                        ind = ind + 1;
                    end
                    addDrawables(obj.plot,newPoints);
                    updateDrawables(obj.plot,obj.gPoints);
                    obj.gPoints = [obj.gPoints, newPoints];
                end
            end
        end
    end
end