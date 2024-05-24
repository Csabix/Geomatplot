classdef ExportFigure < handle
    properties(Access=private)
        finishedLabels = []
        fileID
        go
        colors
    end

    methods(Access=public)
        function o = ExportFigure(go,outputFile)
            keys = {[1 0 0], [0 1 0], [0 0 1], [0 0 0]};
            vals = ["r","g","b","k"];
            o.colors = dictionary(keys,vals);
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
                   o.addLabel(string(moveable.label));
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

        function addLabel(o,label)
            o.finishedLabels = [o.finishedLabels, label];
        end

        function exportDependent(o,dep)
            if isa(dep,'dcircle'); o.exportCircle(dep);
            elseif isa(dep,'dvector'); o.exportVector(dep);
            elseif isa(dep,'dlines'); o.exportdlines(dep);
            elseif isa(dep,'dpoint'); o.exportdpoint(dep);
            elseif isa(dep,'dscalar') %ignore for now, wait for mscalars
            else
                throw(MException('ExportFigure:exportDependent','Unknown type!'));
            end
        end

        function exportCircle(o,circle)
            center = circle.center;
            radius = circle.radius;
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
                    o.colors({circle.fig.Color}) + circle.fig.LineStyle, ...
                    string(circle.fig.LineWidth));
                o.addLabel(string(circle.label));
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
                    o.colors({circle.fig.Color}) + circle.fig.LineStyle, ...
                    string(circle.fig.LineWidth));
                o.addLabel([string(circle.label),string(center.label)]);
            end
        end
        
        function exportdpoint(o,point)
            if ExportFigure.isCallbackNamed(point,'midpoint_')
                o.exportMidpoint(point);
            elseif ExportFigure.isCallbackNamed(point,'equidistpoint') %skip
            elseif ExportFigure.isCallbackNamed(point,'closest') %skip for now!
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
            o.addLabel(string(mp.label));
        end
    
        function exportVector(o,vector)
            A = vector.inputs{1};
            B = vector.inputs{2};
            o.checkLabel(A);
            o.checkLabel(B);
            fprintf(o.fileID,"%s = Vector('%s',%s,%s);\n", ...
                vector.label, vector.label, A.label, B.label);
            o.addLabel(string(vector.label));
        end

        function exportdlines(o,line)
            if ExportFigure.isCallbackNamed(line,'@(a,b)a.value+(b.value-a.value).*[0;1]') || ...
               ExportFigure.isCallbackNamed(line,'@(a,b)a.value+b.value.*[0;1]')
                o.exportLineWithType(line,"Segment");
            elseif ExportFigure.isCallbackNamed(line,'@(a,b)a.value+(b.value-a.value).*[-1e8;-1e4;0;1;1e4;1e8]') || ...
                   ExportFigure.isCallbackNamed(line,'@(a,b)a.value+b.value.*[-1e8;-1e4;0;1;1e4;1e8]')
                if ExportFigure.checkPossiblePerpLine(line); o.exportPerpLinePD(line);
                else; o.exportLineWithType(line,"Line"); end
            elseif ExportFigure.isCallbackNamed(line,'@(a,b)a.value+(b.value-a.value).*[0;1;1e4;1e8]') || ...
                   ExportFigure.isCallbackNamed(line,'@(a,b)a.value+b.value.*[0;1;1e4;1e8]')
                o.exportLineWithType(line,"Ray"); 
            elseif ExportFigure.isCallbackNamed(line,'perpendicular_bisector')
                o.exportLineWithType(line,"PerpendicularBisector"); 
            elseif ExportFigure.isCallbackNamed(line,'perpline2point')
                o.exportLineWithType(line,"PerpendicularLine");
            elseif ExportFigure.isCallbackNamed(line,'perpline2segment')
                o.exportPerpLineSegment(line);
            end
        end

        function exportLineWithType(o,line,type)
            A = line.inputs{1};
            B = line.inputs{2};
            o.checkLabel(A);
            o.checkLabel(B);
            out = "%s = " + type + "('%s',%s,%s,'%s',%s);\n";
            fprintf(o.fileID,out, ...
                line.label, line.label, A.label, B.label, ...
                o.colors({line.fig.Color}) + line.fig.LineStyle, ...
                string(line.fig.LineWidth));
            o.addLabel(string(line.label));
        end

        function exportPerpLineSegment(o,line)
            A = line.inputs{1};
            B = line.inputs{2};
            C = line.inputs{3};
            o.checkLabel(A);
            o.checkLabel(B);
            o.checkLabel(C);
            fprintf(o.fileID,"%s = PerpendicularLine('%s',%s,%s,%s,'%s',%s);\n", ...
                line.label, line.label, A.label, B.label, C.label, ...
                o.colors({line.fig.Color}) + line.fig.LineStyle, ...
                string(line.fig.LineWidth));
            o.addLabel(string(line.label));
        end

        function exportPerpLinePD(o,line)
            A = line.inputs{1};
            B = line.inputs{2}.inputs{2};
            o.checkLabel(A);
            o.checkLabel(B);
            fprintf(o.fileID,"%s = PerpendicularLine('%s',%s,%s,'%s',%s);\n", ...
                line.label, line.label, A.label, B.label, ...
                o.colors({line.fig.Color}) + line.fig.LineStyle, ...
                string(line.fig.LineWidth));
            o.addLabel(string(line.label));
        end
    end % private

    methods(Access=private,Static)
        function is = isCallbackNamed(object,name)
            is = contains(functions(object.callback).function,name);
        end

        function ret = checkPossiblePerpLine(line)
            ret = isa(line.inputs{2},'dpoint') && ExportFigure.isCallbackNamed(line.inputs{2},'closest');
        end
    end % static private
end

