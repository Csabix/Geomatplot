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

        function [size,labels] = checkInputs(o,object)
            size = length(object.inputs);
            labels = strings([1 size]);
            for i = 1:size
                input = object.inputs{i};
                o.checkLabel(input);
                labels(i) = string(input.label);
            end
        end

        function addLabel(o,label)
            o.finishedLabels = [o.finishedLabels, label];
        end

        function exportDependent(o,dep)
            if isa(dep,'dcircle'); o.exportCircle(dep);
            elseif isa(dep,'dcurve'); o.exportdcurve(dep);
            elseif isa(dep,'dvector'); o.exportVector(dep);
            elseif isa(dep,'dlines'); o.exportdlines(dep);
            elseif isa(dep,'dpoint'); o.exportdpoint(dep);
            elseif isa(dep,'dpointseq'); o.exportdpointseq(dep);
            elseif isa(dep,'dpolygon'); o.exportdpolygon(dep);
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
                origCircle = [];
                if isa(center,'dpoint')
                    depFields = fieldnames(o.go.deps);
                    for i = 1:length(depFields)
                        dep = o.go.deps.(depFields{i});
                        if isa(dep,'dcircle') && isequal(dep.center,center.inputs{1})
                           origCircle = dep;
                           break;
                        end
                    end
                end
                if isempty(origCircle)
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
                else; o.exportMirrorCircle(circle,origCircle);
                end
            else
                % 3p input
                [~,labels] = o.checkInputs(center);
                fprintf(o.fileID,"[%s,%s] = Circle('%s',%s,%s,%s,'%s',%s);\n", ...
                    circle.label, ...
                    center.label, ...
                    circle.label, ...
                    labels, ...
                    o.colors({circle.fig.Color}) + circle.fig.LineStyle, ...
                    string(circle.fig.LineWidth));
                o.addLabel([string(circle.label),string(center.label)]);
            end
        end
        
        function exportdpointseq(o,pointseq)
            if ExportFigure.isCallbackNamed(pointseq,'intersect')
                [size,labels] = o.checkInputs(pointseq);
                fprintf(o.fileID,"%s = Intersect(" + ExportFigure.genouts(size) + ");\n", ...
                    pointseq.label, labels);
                o.addLabel(string(pointseq.label));
            end
        end

        function exportdpoint(o,point)
            if ExportFigure.isCallbackNamed(point,'midpoint_')
                o.exportMidpoint(point);
            elseif ExportFigure.isCallbackNamed(point,'equidistpoint') %skip
            elseif ExportFigure.isCallbackNamed(point,'@(x)x.value(i)') % skip
            elseif ExportFigure.isCallbackNamed(point,'mirror_point2')
                o.exportMirrorPoint(point);
            elseif ExportFigure.isCallbackNamed(point,'closest')
                o.exportClosestPoint(point);
            else
                throw(MException('ExportFigure:exportdpoint','Unknown type!'));
            end
        end

        function exportMirrorPoint(o,point)
            depFields = fieldnames(o.go.deps);
            foundCircle = false;
            for i = 1:length(depFields)
                dep = o.go.deps.(depFields{i});
                if isa(dep,'dcircle') && isequal(dep.center,point.inputs{1})
                   foundCircle = true;
                   break;
                end
            end
            if ~foundCircle
                [size,labels] = o.checkInputs(point);
                fprintf(o.fileID,"%s = Mirror('%s'," + ExportFigure.genouts(size) + ",%s,%s);\n", ...
                    point.label, point.label, labels, ...
                    mat2str(point.fig.Color), ...
                    string(point.fig.MarkerSize));
                o.addLabel(string(point.label));
            end
        end

        function exportMirrorCircle(o,circle,original)
            center = circle.center;
            o.checkLabel(original);
            size = length(center.inputs(2:end));
            labels = strings([1 size]);
            for i = 1:length(center.inputs)-1
                input = center.inputs{i+1};
                o.checkLabel(input);
                labels(i) = string(input.label);
            end
            fprintf(o.fileID,"%s = Mirror('%s',%s," + ExportFigure.genouts(size) + ",'%s',%s);\n", ...
                circle.label, circle.label, original.label, labels, ...
                o.colors({circle.fig.Color}) + circle.fig.LineStyle, ...
                string(circle.fig.LineWidth));
            o.addLabel(string(circle.label));
        end

        function exportMirrorLines(o,line)
            [size,labels] = o.checkInputs(line);
            fprintf(o.fileID,"%s = Mirror('%s'," + ExportFigure.genouts(size) + ",'%s',%s);\n", ...
                line.label, line.label, labels, ...
                o.colors({line.fig.Color}) + line.fig.LineStyle, ...
                string(line.fig.LineWidth));
            o.addLabel(string(line.label));
        end

        function exportdcurve(o,curve)
            if ExportFigure.isCallbackNamed(curve,'circ_arc')
                A = curve.inputs{1};
                B = curve.inputs{2}.inputs{2};
                if ExportFigure.isCallbackNamed(curve.inputs{4},'angle_between')
                    C = curve.inputs{4}.inputs{3};
                else; C = curve.inputs{4}; 
                end
                fprintf(o.fileID,"%s = CircularArc('%s',%s,%s,%s,'%s',%s);\n", ...
                    curve.label, curve.label, A.label, B.label, C.label, ...
                    o.colors({curve.fig.Color}) + curve.fig.LineStyle, ...
                    string(curve.fig.LineWidth));
                o.addLabel(string(curve.label));
            else
                [size,labels] = o.checkInputs(curve);
                callback = functions(functions(curve.callback).workspace{1}.usercallback).function;
                fprintf(o.fileID,"%s = Curve('%s'," + ExportFigure.genouts(size) + ",%s,'%s',%s);\n", ...
                    curve.label, curve.label, labels, callback, ...
                    o.colors({curve.fig.Color}) + curve.fig.LineStyle, ...
                    string(curve.fig.LineWidth));
                o.addLabel(string(curve.label));
            end
        end

        function exportdpolygon(o,poly)
            [size,labels] = o.checkInputs(poly);
            fprintf(o.fileID,"%s = Polygon('%s'," + ExportFigure.genouts(size) + ",'%s',%s);\n", ...
                poly.label, poly.label, labels, ...
                o.colors({poly.fig.FaceColor}) + poly.fig.LineStyle, ...
                string(poly.fig.LineWidth));
            o.addLabel(string(poly.label));
        end

        function exportClosestPoint(o,point)
            depFields = fieldnames(o.go.deps);
            isPerpClosestPoint = false;
            for i = 1:length(depFields)
                dep = o.go.deps.(depFields{i});
                if isa(dep,'dlines') && ...
                   ExportFigure.isCallbackNamed(dep,'@(a,b)a.value+(b.value-a.value).*[-1e8;-1e4;0;1;1e4;1e8]') && ...
                   isequal(dep.inputs{2},point)
                   isPerpClosestPoint = true;
                   break;
                end
            end
            if ~isPerpClosestPoint
                [size,labels] = o.checkInputs(point);
                fprintf(o.fileID,"%s = ClosestPoint('%s',"+ ExportFigure.genouts(size) + ",%s,%s);\n", ...
                    point.label, point.label, labels, ...
                    mat2str(point.fig.Color), ...
                    string(point.fig.MarkerSize));
                o.addLabel(string(point.label));
            end
        end
        
        function exportMidpoint(o,mp)
            [size,labels] = o.checkInputs(mp);
            fprintf(o.fileID,"%s = Midpoint('%s'," + ExportFigure.genouts(size) +",%s,%s);\n", ...
                mp.label, mp.label, labels, ...
                mat2str(mp.fig.Color), ...
                string(mp.fig.MarkerSize));
            o.addLabel(string(mp.label));
        end
    
        function exportVector(o,vector)
            [size,labels] = o.checkInputs(vector);
            fprintf(o.fileID,"%s = Vector('%s'," + ExportFigure.genouts(size) + ");\n", ...
                vector.label, vector.label, labels);
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
            elseif ExportFigure.isCallbackNamed(line,'perpline2point') || ...
                   ExportFigure.isCallbackNamed(line,'perpline2segment')
                o.exportLineWithType(line,"PerpendicularLine");
            elseif ExportFigure.isCallbackNamed(line,'angle_bisector3') || ...
                   ExportFigure.isCallbackNamed(line,'angle_bisector4')
                o.exportLineWithType(line,"AngleBisector");
            elseif ExportFigure.isCallbackNamed(line,'segmentseq_concat')
                o.exportSegmentSequence(line);
            elseif ExportFigure.isCallbackNamed(line,'mirror_point')
                o.exportMirrorLines(line);
            end
        end

        function exportLineWithType(o,line,type)
            [size,labels] = o.checkInputs(line);
            out = "%s = " + type + "('%s'," + ExportFigure.genouts(size) + ",'%s',%s);\n";
            fprintf(o.fileID,out, ...
                line.label, line.label, labels, ...
                o.colors({line.fig.Color}) + line.fig.LineStyle, ...
                string(line.fig.LineWidth));
            o.addLabel(string(line.label));
        end

        function exportSegmentSequence(o,seq)
            [size,labels] = o.checkInputs(seq);
            breakEvery = 0;
            if size > 2 && isnan(seq.fig.XData(3))
                breakEvery = 2;
            elseif size > 3 && isnan(seq.fig.XData(4))
                breakEvery = 3;
            end
            fprintf(o.fileID,"%s = SegmentSequence('%s'," + ExportFigure.genouts(size) + ",%s,'%s',%s);\n", ...
                seq.label, seq.label, labels, ...
                string(breakEvery), o.colors({seq.fig.Color}) + seq.fig.LineStyle, ...
                string(seq.fig.LineWidth));
            o.addLabel(string(seq.label));
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

        function expStr = genouts(size)
            expStr = strjoin(repmat("%s",1,size),',');
        end
    end % static private
end

