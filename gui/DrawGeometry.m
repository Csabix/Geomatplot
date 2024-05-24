classdef DrawGeometry
    methods(Access = public,Static)
        function drawPoint(o,data)
            point = data{1};
            Point(o,[point.x point.y],'b');
        end

        function drawSegment(o,data)
            Segment(o,data{1},data{2});
        end

        function drawLine(o,data)
            Line(o,data{1},data{2});
        end

        function drawCircle3(o,data)
            Circle(o,data{1},data{2},data{3});
        end

        function drawCircle2(o,data)
            Circle(o,data{1},data{2});
        end

        function drawMidpoint(o,data)
            Midpoint(o,data{1},data{2});
        end

        function drawPerpendicularBisector(o,data)
            PerpendicularBisector(o,data{1},data{2},':');
        end

        function drawAngleBisector3(o,data)
            AngleBisector(o,data{1},data{2},data{3},':');
        end
    
        function drawPolygon(o,data)
            Polygon(o,data);
        end

        function drawAngleBisector4(o,data)
            AngleBisector(o,data{1},data{2},data{3},data{4},':');
        end

        function drawCircularArc(o,data)
            CircularArc(o,data{1},data{2},data{3});
        end

        function drawPerpendicularLine3(o,data)
            PerpendicularLine(o,data{1},data{2},data{3});
        end

        function drawPerpendicularLine2(o,data)
            PerpendicularLine(o,data{1},data{2});
        end

        function drawRay(o,data)
            Ray(o,data{1},data{2});
        end

        function drawVector(o,data)
            Vector(o,data{1},data{2});
        end

        function drawIntersection(o,data)
            Intersect(o,data{1},data{2});
        end

        function drawMirror(o,data)
            Mirror(o,data{1},data{2});
        end

        function drawClosestPoint(o,data)
            ClosestPoint(o,data{1},data{2});
        end

        function drawSegmentSequence(o,data,breakEvery)
            if isempty(breakEvery); breakEvery = 'lines'; end
            SegmentSequence(o,data,breakEvery);
        end

        function drawCentroidPoint(o,data)
            Midpoint(o,data);
        end

        function drawMirrorSegment(o,data)
            Mirror(o,data{1},data{2},data{3});
        end

        function drawBezier2(o,data)
           fun = @(t,p0,p1,p2)  p0.*(1-t).^2 + 2*p1.*t.*(1-t) + p2.*t.^2;
           Curve(o,data{1},data{2},data{3},fun);
        end

        function drawBezier3(o,data)
            fun = @(t,p0,p1,p2,p3)  p0.*(1-t).^3 + 3*p1.*t.*(1-t).^2 + 3*p2.*(1-t).*t.^2 + p3.*t.^3;
            Curve(o,data{1},data{2},data{3},data{4},fun);
        end
    end % static public
end
