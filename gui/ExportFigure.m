classdef ExportFigure < handle
    properties(Access=private)
        finishedLabels = []
        fileID
        go
    end

    methods(Access=public)
        function o = ExportFigure(go,outputFile)
            o.go = go;
            fileID = fopen(outputFile,'w');
            fprintf(fileID,"clf; %% %s\n",outputFile);
            o.fileID = fileID;
            movFields = fieldnames(go.movs);
            o.finishedLabels = [];
            for i = 1:length(movFields)
                moveable = go.movs.(movFields{i});
                if isa(moveable,'mpoint')
                    fprintf(fileID,"%s = Point('%s',%s,%s,%s);\n", ...
                        moveable.label, ...
                        moveable.label, ...
                        mat2str(moveable.value), ...
                        mat2str(moveable.fig.Color), ...
                        string(moveable.fig.MarkerSize));
                   o.finishedLabels = [o.finishedLabels, string(moveable.label)];
                end
            end
            depFields = fieldnames(go.deps);
            for i = 1:length(depFields)
                dep = go.deps.(depFields{i});
                o.exportDependent(dep);
            end
            fclose(fileID);
        end
    end % public

    methods(Access=private)
        function checkLabel(o,object)
            missing = ~ismember(object.label,o.finishedLabels);
            if missing
                if isa(object,'dependent')
                    o.exportDependent(object);
                end
            end
        end

        function exportDependent(o,dep)
            if isa(dep,'dcircle'); o.exportCircle(dep);
            elseif isa(dep,'dpoint'); o.exportdpoint(dep);
            elseif isa(dep,'dscalar') %ignore for now, wait for mscalars
            else
                throw(MException('ExportFigure:exportDependent','Unknown type!'));
            end
        end

        function exportCircle(o,circle)
            center = circle.center;
            radius = circle.radius;
            %Circle color input not supported yet!
            if isa(center,'mpoint') || ...
               (isa(center,'dpoint') && center.inputs{1}~=radius.inputs{2})
                %2p input
                radPoint = radius.inputs{2};
                o.checkLabel(center);
                o.checkLabel(radPoint);
                fprintf(o.fileID,"%s = Circle('%s',%s,%s,'%s',%s);\n", ...
                    circle.label, ...
                    circle.label, ...
                    center.label, ...
                    radPoint.label, ...
                    circle.fig.LineStyle, ...
                    string(circle.fig.LineWidth));
                o.finishedLabels = [o.finishedLabels,string(circle.label)];
            else
                % 3p input
                circleInputs = center.inputs;
                for i = 1:3
                    o.checkLabel(circleInputs{i});
                end
                fprintf(o.fileID,"[%s,%s] = Circle('%s',%s,%s,%s,'%s',%s);\n", ...
                    circle.label, ...
                    center.label, ...
                    circle.label, ...
                    circleInputs{1}.label, ...
                    circleInputs{2}.label, ...
                    circleInputs{3}.label, ...
                    circle.fig.LineStyle, ...
                    string(circle.fig.LineWidth));
                o.finishedLabels = [o.finishedLabels, ...
                    string(circle.label),string(center.label)];
            end
        end
        
        function exportdpoint(o,point)
            if ExportFigure.isCallbackNamed(point,'midpoint_')
                o.exportMidpoint(point);
            elseif ExportFigure.isCallbackNamed(point,'equidistpoint') %skip
            else
                throw(MException('ExportFigure:exportdpoint','Unknown type!'));
            end
        end
        
        function exportMidpoint(o,mp)
            A = mp.inputs{1};
            B = mp.inputs{2};
            o.checkLabel(A);
            o.checkLabel(B);
            fprintf(o.fileID,"%s = Midpoint('%s',%s,%s);\n", ...
                mp.label, mp.label, A.label, B.label);
            o.finishedLabels = [o.finishedLabels,string(mp.label)];
        end
    end % private

    methods(Access=private,Static)
        function is = isCallbackNamed(object,name)
            is = contains(functions(object.callback).function,name);
        end
    end % static private
end

