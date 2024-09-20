classdef ImportScript < handle
    properties (Constant)
        %Point includes ClosestPoint
        %Line includes PerpendicularLine,ParallelLine
        GeomatplotTypes = {'Point', 'Circle', 'Mirror', 'Intersect', ...
                           'CircularArc', 'Curve', 'Polygon', ...
                           'Midpoint', 'Vector', 'Segment', 'Line', ...
                           'Ray', 'PerpendicularBisector', ...
                           'AngleBisector', 'SegmentSequence'};
    end

    methods(Access=public)
        function o = ImportScript(app,inputFile,go) %#ok<INUSD>
            inputData = strjoin(importdata(inputFile),'\n');
            inputData = regexprep(inputData, 'clf;', '');

            for i = 1:length(o.GeomatplotTypes)
                inputData = regexprep(inputData, ...
                                [o.GeomatplotTypes{i} '\('], ...
                                [o.GeomatplotTypes{i} '(go,']);
            end
            inputData = regexprep(inputData, ...
                                '([A-Za-z0-9]+)\s*=\s*Distance\(([^)]*)\);', ...
                                '$1 = Distance(go,$2); app.createDistanceUI($1);');
            eval(inputData);
        end
    end
end