classdef ImportScript < handle
    properties (Constant)
        %Point includes ClosestPoint
        %Line includes PerpendicularLine,ParallelLine
        GeomatplotTypes = {'Point', 'Circle', 'Mirror', 'Intersect', ...
                           'CircularArc', 'Curve', 'Polygon', ...
                           'Midpoint', 'Vector', 'Segment', 'Line', ...
                           'Ray', 'PerpendicularBisector', ...
                           'AngleBisector', 'SegmentSequence', ...
                           'Distance', ... %Non-UI editable Geomatplot Types:
                           'Text', 'Eval', 'CustomValue', 'Scalar', ...
                           'PointSequence','drawSliderX'};
        UnsupportedTypes = {'Image'};
    end

    methods(Access=public)
        function o = ImportScript(app,inputFile,go,folderName) %#ok<INUSD>
            inputData = strjoin(importdata(inputFile),'\n');
            inputData = regexprep(inputData, 'clf;', '');

            for i = 1:length(o.UnsupportedTypes)
                match = regexp(inputData,[o.UnsupportedTypes{i} '\('],'match');
                if ~isempty(match)
                    uialert(go.ax.Parent ...
                        ,"Import failed." + newline + ...
                         "The file contains unsupported type: '" + o.UnsupportedTypes{i} + "'!", ...
                        "Unsupported Type");
                    return;
                end
            end

            inputData = regexprep(inputData,'xlim\(([^)]*)\);','go.ax.XLim = $1;');
            inputData = regexprep(inputData,'ylim\(([^)]*)\);','go.ax.YLim = $1;');

            for i = 1:length(o.GeomatplotTypes)
                inputData = regexprep(inputData, ...
                                [o.GeomatplotTypes{i} '\('], ...
                                [o.GeomatplotTypes{i} '(go,']);
            end
            inputData = regexprep(inputData, ...
                                '([A-Za-z0-9]+)\s*=\s*(Distance\([^)]*\));', ...
                                '$1 = $2; app.createDistanceUI($1);');

            inputData = regexprep(inputData, ...
                                'drawSliderX\((.*?)(?<!(''|")Visible("|''))\);', ...
                                'drawSliderX($1,''Visible'',''off'');');
            
            funcPattern = '\nfunction[^\n]*\n(?:[^\n]*\n)*?end';
            functions = regexp(inputData,funcPattern,'match');

            code = regexprep(inputData,funcPattern,'');

            ImportScript.createTempFunctions(folderName,functions);

            eval(code);
        end
    end

    methods(Access=private,Static)
        function createTempFunctions(dirName,functions)
            if isempty(functions); return; end

            if ~exist(dirName, 'dir')
                mkdir(dirName);
            end
            
            for i = 1:length(functions)
                fileName = regexp(functions{i},'\nfunction(\s.*?=\s|\s)(\w+)\(', ...
                    'tokens');
                fid = fopen([dirName '\\' fileName{1}{2} '.m'], 'w');
                fprintf(fid, '%s\n\n', functions{i});
                fclose(fid);
            end
            
            addpath([pwd '\\' dirName]);
        end
    end
end