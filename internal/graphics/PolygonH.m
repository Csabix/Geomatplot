classdef PolygonH < handle
    properties (Dependent=true,SetObservable=true)
        Position,
        PrimaryColor,
        BorderColor,
        FaceAlpha
    end
    
    properties
        gPolygon
        plot Plot
        UserData
    end

    properties(Access=private)
        lastX
        lastY
    end

    events
        Moved
    end
    
    methods
        function obj = PolygonH(gPolygon,plot)
            obj.gPolygon = gPolygon;
            obj.plot = plot;
            obj.lastX = gPolygon.x;
            obj.lastY = gPolygon.y;
            addlistener(obj,["Position","PrimaryColor","BorderColor","FaceAlpha"],'PostSet',@obj.updateBuffer);

            gPolygonH = handle(obj.gPolygon,'CallbackProperties');
            set(gPolygonH,'MovementCallback',@obj.MovementCallback);
        end
        
        function x = get.Position(obj)
            x = [obj.gPolygon.x, obj.gPolygon.y];
        end
        
        function set.Position(obj,position)
            s1 = size(position);
            s2 = size(obj.gPolygon.x);
            
            x = position(:,1);
            y = position(:,2);
            if (s1(1) == s2(1))
                indices = obj.gPolygon.indices + 1;
                if any(triangleAreas(position, indices) < 0)
                    [x,y,indices] = PolygonH.calcDeluany(x,y);
                end
                obj.gPolygon.x = x;
                obj.gPolygon.y = y;
                obj.gPolygon.indices = indices - 1;
                obj.lastX = x;
                obj.lastY = y;
            else
                [x,y,indices] = PolygonH.calcDeluany(x,y);
                pc = obj.gPolygon.primaryColors;
                bc = obj.gPolygon.borderColors;
                fa = obj.gPolygon.faceAlpha;
                mo = obj.gPolygon.isMovable();
                newPolygon = GeomatPlot.Draw.gPolygon(x,y, indices-1, pc, bc, fa,mo);
                obj.plot.removeDrawable(obj.gPolygon);
                obj.gPolygon = newPolygon;
                obj.plot.addDrawable(obj.gPolygon);
                obj.lastX = x;
                obj.lastY = y;
            end
        end

        function updateBuffer(obj,~,~)
            notify(obj,'Moved');
            obj.plot.updateDrawable(obj.gPolygon);
        end

        function MovementCallback(obj,~,~)
            position = [obj.gPolygon.x, obj.gPolygon.y];
            indices = obj.gPolygon.indices + 1;
            currentCount = size(position,1);
            if any(triangleAreas(position, indices) < 0)
                x = obj.gPolygon.x;
                y = obj.gPolygon.y;
                [x,y,indices] = PolygonH.calcDeluany(x,y);
                if numel(x) == currentCount
                    obj.gPolygon.x = x;
                    obj.gPolygon.y = y;
                    obj.gPolygon.indices = indices - 1;
                    obj.plot.updateDrawable(obj.gPolygon);
                    obj.lastX = x;
                    obj.lastY = y;
                else
                    obj.Position = [obj.lastX,obj.lastY];
                end
            else
                obj.lastX = position(:,1);
                obj.lastY = position(:,2);
            end
            
            notify(obj,'Moved');
        end
    end

    methods(Static)
    
        function [x, y, indices] = calcDeluany(x,y)
            count = numel(x);
            
            P = zeros(count,2);
            for i = 1:count
                P(i,:) = [x(i),y(i)];
            end

            C = zeros(count, 2);
            for i = 1:(count-1)
                C(i,:) = [i, i + 1];
            end
            C(count,:) = [count, 1];

            DT = delaunayTriangulation(P,C);
            IO = isInterior(DT);
            indices = DT(IO, :);
            x = DT.Points(:,1);
            y = DT.Points(:,2);
        end
    
    end
end

