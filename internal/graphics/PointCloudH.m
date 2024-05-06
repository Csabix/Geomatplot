classdef PointCloudH < handle
    properties (Dependent=true,SetObservable=true)
        %Position
    end

    properties (SetObservable=true)
        Position,
        PrimaryColor,
        Width
    end

    properties
        gPoints
        Visible
        plot Plot
        UserData
    end

    events
        Moved
    end
    
    methods
        function obj = PointCloudH(position,plot,color,width,visible)
            obj.Visible = visible;
            %if visible
            %    pC = size(position,1);
            %    obj.gPoints = repmat(java.lang.Object,1,pC);
    %
            %    for i = 1:pC
            %        point = GeomatPlot.Draw.gPoint(position(i,1),position(i,2), color, width,0,false);
            %        %plot.addDrawable(point);
            %        obj.gPoints(i) = point;
            %    end
            %else
            %    obj.gPoints = [];
            %end
            obj.gPoints = [];

            obj.plot = plot;
            obj.Width = width;
            obj.PrimaryColor = color;
            obj.Position = position;
            addlistener(obj,["Position","PrimaryColor","Width"],'PostSet',@obj.updateBuffer);
        end
        
        function updateBuffer(obj,~,~)
            notify(obj,'Moved');
            for i = 1:numel(obj.gPoints)
                obj.plot.updateDrawable(obj.gPoints(i));
            end
        end

        %function position = get.Position(obj)
        %    position = obj.Position;
        %end
        
        function set.Position(obj,position)
            oldCount = size(obj.Position,1);
            currentCount = size(position,1);

            obj.Position = position;

            if obj.Visible
                if oldCount == currentCount
                    for i = 1:currentCount
                        currentPoint = obj.gPoints(i);
                        currentPoint.x = position(i,1);
                        currentPoint.y = position(i,2);
                    end
                    
                elseif oldCount > currentCount
                    for i = 1:currentCount
                        currentPoint = obj.gPoints(i);
                        currentPoint.x = position(i,1);
                        currentPoint.y = position(i,2);
                    end
                    toRemove = obj.gPoints(currentCount+1:end);
                    obj.gPoints = obj.gPoints(1:currentCount);
                    
                    plt = obj.plot;
                    for i = 1:numel(toRemove)
                        plt.removeDrawable(toRemove(i));
                    end
                else
                    for i = 1:oldCount
                        currentPoint = obj.gPoints(i);
                        currentPoint.x = position(i,1);
                        currentPoint.y = position(i,2);
                    end

                    newPoints = repmat(java.lang.Object,1,currentCount - oldCount);
                    ind = 1;
                    c = obj.PrimaryColor;
                    w = obj.Width;

                    plt = obj.plot;
                    for i = (oldCount+1):currentCount
                        point = GeomatPlot.Draw.gPoint(position(i,1),position(i,2), c, w,0,false);
                        plt.addDrawable(point);
                        newPoints(ind) = point;
                        ind = ind + 1;
                    end

                    obj.gPoints = [obj.gPoints, newPoints];
                end
                
                plt = obj.plot;
                for i = 1:numel(obj.gPoints)
                    plt.updateDrawable(obj.gPoints(i));
                end

            end
        end
    end
end



%classdef PointCloudH < handle
%    properties (Dependent=true,SetObservable=true)
%        Position
%    end
%
%    properties (SetObservable=true)
%        PrimaryColor,
%        Width
%    end
%
%    properties
%        gPoints
%        plot Plot
%        UserData
%    end
%
%    events
%        Moved
%    end
%    
%    methods
%        function obj = PointCloudH(gPoints,plot,color,width)
%            obj.gPoints = gPoints;
%            obj.plot = plot;
%            obj.Width = width;
%            obj.PrimaryColor = color;
%            addlistener(obj,["Position","PrimaryColor","Width"],'PostSet',@obj.updateBuffer);
%        end
%        
%        function updateBuffer(obj,~,~)
%            notify(obj,'Moved');
%            for i = 1:numel(obj.gPoints)
%                obj.plot.updateDrawable(obj.gPoints(i));
%            end
%        end
%
%        function position = get.Position(obj)
%            position = zeros(numel(obj.gPoints), 2);
%            for i = 1:numel(obj.gPoints)
%                position(i,:) = [obj.gPoints(i).x,obj.gPoints(i).y];
%            end
%        end
%        
%        function set.Position(obj,position)
%            positionCount = size(position,1);
%            currentCount = numel(obj.gPoints);
%            if positionCount == currentCount
%                for i = 1:positionCount
%                    current = obj.gPoints(i);
%                    current.x = position(i,1);
%                    current.y = position(i,2);
%                end
%            elseif positionCount < currentCount
%                for i = 1:positionCount
%                    current = obj.gPoints(i);
%                    current.x = position(i,1);
%                    current.y = position(i,2);
%                end
%                remainder = obj.gPoints(positionCount+1:end);
%                obj.gPoints = obj.gPoints(1:positionCount);
%
%                for i = 1:numel(remainder)
%                    obj.plot.removeDrawable(remainder(i));
%                end
%
%            elseif positionCount > currentCount
%                for i = 1:currentCount
%                    current = obj.gPoints(i);
%                    current.x = position(i,1);
%                    current.y = position(i,2);
%                end
%
%                newpoints = [];
%
%                for i = currentCount+1:positionCount
%                    point = GeomatPlot.Draw.gPoint(position(i,1),position(i,2), obj.PrimaryColor, obj.Width,0,false);
%                    obj.plot.addDrawable(point)
%                    newpoints = [newpoints, point];
%                end
%                obj.gPoints = [obj.gPoints, newpoints];
%            end
%
%            for i = 1:numel(obj.gPoints)
%                obj.plot.updateDrawable(obj.gPoints(i));
%            end
%        end
%
%    end
%end

