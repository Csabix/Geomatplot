classdef ExportFigure
    methods(Access=public,Static)
        function export(go,output)
            fileID = fopen(output,'w');
            movFields = fieldnames(go.movs);
            for i = 1:length(movFields)
                moveable = go.movs.(movFields{i});
                if isa(moveable,'mpoint')
                    fprintf(fileID,"%s = Point(%s,%s,%s);\n", ...
                        moveable.label, ...
                        mat2str(moveable.value), ...
                        mat2str(moveable.fig.Color), ...
                        string(moveable.fig.MarkerSize));
                end
            end
            fclose(fileID);
        end
    end

    methods(Access=private,Static)
    end
end

