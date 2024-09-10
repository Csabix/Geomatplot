classdef ImportScript < handle
    properties (Constant)
        %Point changes ClosestPoint
        %Line changes PerpendicularLine,ParallelLine
        GeomatplotTypes = {'Point', 'Circle', 'Mirror', 'Intersect', ...
                           'CircularArc', 'Curve', 'Polygon', ...
                           'Midpoint', 'Vector', 'Segment', 'Line', ...
                           'Ray', 'PerpendicularBisector', ...
                           'AngleBisector', 'SegmentSequence'};
    end

    methods(Access=public)
        function o = ImportScript(go,inputFile)
            inputData = strjoin(importdata(inputFile),'\n');
            inputData = regexprep(inputData, ['clf;'], '');

            for i = 1:length(o.GeomatplotTypes)
                inputData = regexprep(inputData, ...
                                [o.GeomatplotTypes{i} '\('], ...
                                [o.GeomatplotTypes{i} '(go,']);
            end

            eval(inputData);
        end
    end
end