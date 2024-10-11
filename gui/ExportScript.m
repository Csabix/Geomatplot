classdef ExportScript < handle
    properties(Access=private)
        finishedLabels = []
        fileID
        go
        decimals
    end

    methods(Access=public)
        function o = ExportScript(go,outputFile,inputs,tempfolder)
            o.go = go;
            o.finishedLabels = [];
            o.decimals = inputs{1};
            fileID = fopen(outputFile,'w');
            o.fileID = fileID;
            if inputs{2} ~= 0; fprintf(fileID,"clf; "); end
            if inputs{3} ~= 0; fprintf(fileID,"%% %s",outputFile); end

            fprintf(fileID,"\n");
            movFields = fieldnames(go.movs);
            for i = 1:length(movFields)
                moveable = go.movs.(movFields{i});
                if isa(moveable,'mpoint')
                    fprintf(fileID,"%s = Point('%s',%s,%s,%s);\n", ...
                        moveable.label, ...
                        moveable.label, ...
                        ExportScript.formatValue(moveable.value,o.decimals), ...
                        mat2str(moveable.fig.Color), ...
                        string(moveable.fig.MarkerSize));
                   o.addLabel(string(moveable.label));
                elseif isa(moveable,'mpolygon')
                    fprintf(fileID,"%s = Polygon('%s',%s);\n", ...
                        moveable.label, ...
                        moveable.label, ...
                        ExportScript.formatmpoly(moveable.fig.Position,o.decimals));
                end
            end
            depFields = fieldnames(go.deps);
            for i = 1:length(depFields)
                dep = go.deps.(depFields{i});
                o.exportDependent(dep);
            end
            
            %Lims
            if inputs{4} ~= 0
                fprintf(fileID,"\nxlim(%s); ylim(%s);\n", ...
                    ExportScript.formatValue(go.ax.XLim,o.decimals), ...
                    ExportScript.formatValue(go.ax.YLim,o.decimals));
            end

            %Functions
            if exist(tempfolder, 'dir')
                fileList = {dir(fullfile(tempfolder, '*.m')).name};
                for i = 1:length(fileList)
                    rawdata = importdata(fileList{i});
                    if isempty(rawdata); continue; end
                    fData = strjoin(rawdata,'\n');
                    fprintf(fileID,"\n%s\n",fData);
                end
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
            elseif isa(dep,'dscalar'); o.exportdscalar(dep);
            elseif isa(dep,'dtext'); o.exportdtext(dep);
            elseif isa(dep,'dcustomvalue'); o.exportdcustomvalue(dep);
            else
                throw(MException('ExportFigure:exportDependent','Unknown type!'));
            end
        end

        function exportCircle(o,circle)
            center = circle.center;
            radius = circle.radius;
            if isa(center,'dpoint') && ...
                ExportScript.isCallbackNamed(center,'equidistpoint')
                % 3p input
                [~,labels] = o.checkInputs(center);
                fprintf(o.fileID,"[%s,%s,%s] = Circle('%s',%s,%s,%s,'%s',%s,'Color',%s);\n", ...
                    circle.label, ...
                    center.label, ...
                    radius.label, ...
                    circle.label, ...
                    labels, ...
                    circle.fig.LineStyle, ...
                    string(circle.fig.LineWidth), ...
                    mat2str(circle.fig.Color));
                o.addLabel([string(circle.label),string(center.label)]);
            else
                %2p input
                origCircle = [];
                if isa(center,'dpoint')
                    depFields = fieldnames(o.go.deps);
                    for i = 1:length(depFields)
                        dep = o.go.deps.(depFields{i});
                        if ~isequal(dep,circle) && isa(dep,'dcircle') && ...
                            isequal(dep.center,center.inputs{1}) && ...
                            ExportScript.isCallbackNamed(center,'mirror_point2')
                           origCircle = dep;
                           break;
                        end
                    end
                end
                if isempty(origCircle)
                    if isempty(circle.gen_dist) 
                        o.checkLabel(radius);
                        radPoint = radius;
                    else
                        radPoint = radius.inputs{2};
                        o.checkLabel(radPoint);
                    end
                    o.checkLabel(center);
                    fprintf(o.fileID,"[%s,~,%s] = Circle('%s',%s,%s,'%s',%s,'Color',%s);\n", ...
                        circle.label, ...
                        ExportScript.circleRadiusName(circle), ...
                        circle.label, ...
                        center.label, ...
                        radPoint.label, ...
                        circle.fig.LineStyle, ...
                        string(circle.fig.LineWidth), ...
                        mat2str(circle.fig.Color));
                    o.addLabel(string(circle.label));
                else; o.exportMirrorCircle(circle,origCircle);
                end
            end
        end
        
        function exportdpointseq(o,pts)
            if ExportScript.isCallbackNamed(pts,'intersect')
                [size,labels] = o.checkInputs(pts);
                firstPoint = [];
                depFields = fieldnames(o.go.deps);
                for i = 1:length(depFields)
                    dep = o.go.deps.(depFields{i});
                    if isa(dep,'dpoint') && isequal(length(dep.inputs), 1) ...
                        && isequal(dep.inputs{1},pts)
                        firstPoint = dep;
                        break;
                    end
                end
                if isempty(firstPoint); name = pts.label;
                else; name = firstPoint.label; end
                fprintf(o.fileID,"%s = Intersect(" + ExportScript.genouts(size) + ");\n", ...
                    name, labels);
            else
                [size,labels] = o.checkInputs(pts);
                if ExportScript.isCallbackNamed(pts,'pointseq_concat')
                    fprintf(o.fileID,"%s = PointSequence(" + ExportScript.genouts(size) + ",%s,%s);\n", ...
                        pts.label, labels, ...
                        mat2str(pts.fig.MarkerFaceColor), ...
                        num2str(pts.fig.SizeData/16));
                else
                    callbackname = ExportScript.getusercallback(pts);
                    fprintf(o.fileID,"%s = PointSequence(" + ExportScript.genouts(size) + ",%s,%s,%s);\n", ...
                        pts.label, labels, callbackname,...
                        mat2str(pts.fig.MarkerFaceColor), ...
                        num2str(pts.fig.SizeData/16));
                end
            end
            o.addLabel(string(pts.label));
        end

        function exportdpoint(o,point)
            if ExportScript.isCallbackNamed(point,'midpoint_')
                o.exportMidpoint(point);
            elseif ExportScript.isCallbackNamed(point,'equidistpoint') %skip
            elseif ExportScript.isCallbackNamed(point,'@(x)x.value(i)') % skip
            elseif ExportScript.isCallbackNamed(point,'mirror_point2')
                o.exportMirrorPoint(point);
            elseif ExportScript.isCallbackNamed(point,'closest')
                o.exportClosestPoint(point);
            elseif ExportScript.isCallbackNamed(point,'Point/internalcallback')
                o.exportCallbackPoint(point);
            else
                o.exportEval(point);
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
                fprintf(o.fileID,"%s = Mirror('%s'," + ExportScript.genouts(size) + ",%s,%s);\n", ...
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
            fprintf(o.fileID,"%s = Mirror('%s',%s," + ExportScript.genouts(size) + "," + ...
                "'%s',%s,'Color',%s);\n", ...
                circle.label, circle.label, original.label, labels, ...
                circle.fig.LineStyle, ...
                string(circle.fig.LineWidth), ...
                mat2str(circle.fig.Color));
            o.addLabel(string(circle.label));
        end

        function exportMirrorLines(o,line)
            [size,labels] = o.checkInputs(line);
            fprintf(o.fileID,"%s = Mirror('%s'," + ExportScript.genouts(size) + "," + ...
                "'%s',%s,'Color',%s);\n", ...
                line.label, line.label, labels, ...
                line.fig.LineStyle, ...
                string(line.fig.LineWidth), ...
                mat2str(line.fig.Color));
            o.addLabel(string(line.label));
        end

        function exportdcurve(o,curve)
            if ExportScript.isCallbackNamed(curve,'circ_arc')
                A = curve.inputs{1};
                B = curve.inputs{2}.inputs{2};
                if ExportScript.isCallbackNamed(curve.inputs{4},'angle_between')
                    C = curve.inputs{4}.inputs{3};
                else; C = curve.inputs{4}; 
                end
                fprintf(o.fileID,"%s = CircularArc('%s',%s,%s,%s,'%s',%s,'Color',%s);\n", ...
                    curve.label, curve.label, A.label, B.label, C.label, ...
                    curve.fig.LineStyle, ...
                    string(curve.fig.LineWidth), ...
                    mat2str(curve.fig.Color));
                o.addLabel(string(curve.label));
            else
                [size,labels] = o.checkInputs(curve);
                callback = ExportScript.getusercallback(curve);
                fprintf(o.fileID,"%s = Curve('%s'," + ExportScript.genouts(size) + "," + ...
                    "%s,'%s',%s,'Color',%s);\n", ...
                    curve.label, curve.label, labels, callback, ...
                    curve.fig.LineStyle, ...
                    string(curve.fig.LineWidth), ...
                    mat2str(curve.fig.Color));
                o.addLabel(string(curve.label));
            end
        end

        function exportdpolygon(o,poly)
            [size,labels] = o.checkInputs(poly);
            fprintf(o.fileID,"%s = Polygon('%s'," + ExportScript.genouts(size) + "," + ...
                "'%s',%s,'Color',%s);\n", ...
                poly.label, poly.label, labels, ...
                poly.fig.LineStyle, ...
                string(poly.fig.LineWidth), ...
                mat2str(poly.fig.FaceColor));
            o.addLabel(string(poly.label));
        end

        function exportClosestPoint(o,point)
            depFields = fieldnames(o.go.deps);
            isPerpClosestPoint = false;
            for i = 1:length(depFields)
                dep = o.go.deps.(depFields{i});
                if isa(dep,'dlines') && ...
                   ExportScript.isCallbackNamed(dep,'@(a,b)a.value+(b.value-a.value).*[-1e8;-1e4;0;1;1e4;1e8]') && ...
                   isequal(dep.inputs{2},point)
                   isPerpClosestPoint = true;
                   break;
                end
            end
            if ~isPerpClosestPoint
                [size,labels] = o.checkInputs(point);
                fprintf(o.fileID,"%s = ClosestPoint('%s',"+ ExportScript.genouts(size) + ",%s,%s);\n", ...
                    point.label, point.label, labels, ...
                    mat2str(point.fig.Color), ...
                    string(point.fig.MarkerSize));
                o.addLabel(string(point.label));
            end
        end

        function exportMidpoint(o,mp)
            [size,labels] = o.checkInputs(mp);
            fprintf(o.fileID,"%s = Midpoint('%s'," + ExportScript.genouts(size) +",%s,%s);\n", ...
                mp.label, mp.label, labels, ...
                mat2str(mp.fig.Color), ...
                string(mp.fig.MarkerSize));
            o.addLabel(string(mp.label));
        end

        function exportCallbackPoint(o,point)
            callbackname = ExportScript.getusercallback(point);
            [size,labels] = o.checkInputs(point);
            fprintf(o.fileID,"%s = Point('%s'," + ExportScript.genouts(size) +",%s);\n", ...
                point.label, point.label, labels, callbackname);
            o.addLabel(string(point.label));
        end
    
        function exportVector(o,vector)
            if ExportScript.isCallbackNamed(vector,'@(a,b) b.value-a.value')
                [size,labels] = o.checkInputs(vector);
                fprintf(o.fileID,"%s = Vector('%s'," + ExportScript.genouts(size) + ");\n", ...
                    vector.label, vector.label, labels);
                o.addLabel(string(vector.label));
            else %Eval
                o.exportEval(vector);
            end
        end

        function exportdtext(o,text)
            func = functions(text.callback).function;
            switch func
                case "Text/text_constPos_constStr"
                    fprintf(o.fileID,"%s = Text(%s,'%s');\n", ...
                        text.label, ...
                        ExportScript.formatValue(text.fig.Position(1:2),o.decimals), ...
                        replace(text.fig.String,' ',''));
                case "Text/text_constPos_varStr"
                    callbackname = ExportScript.getusercallback(text);
                    [size,labels] = o.checkInputs(text);
                    fprintf(o.fileID,"%s = Text(%s," + ExportScript.genouts(size) + ",%s);\n", ...
                        text.label, ...
                        ExportScript.formatValue(text.fig.Position(1:2),o.decimals), ...
                        labels, callbackname);
                case "Text/text_constPos_printDrawing"
                    fprintf(o.fileID,"%s = Text(%s,%s);\n", ...
                        text.label, ...
                        ExportScript.formatValue(text.fig.Position(1:2),o.decimals), ...
                        text.inputs{1}.label);
                case "Text/text_varPos_constStr"
                    fprintf(o.fileID,"%s = Text(%s,'%s');\n", ...
                        text.label, ...
                        text.inputs{1}.label, ...
                        replace(text.fig.String,' ',''));
                case "Text/text_varPos_varStr"
                    callbackname = ExportScript.getusercallback(text);
                    [size,labels] = o.checkInputs(text);
                        fprintf(o.fileID,"%s = Text(" + ExportScript.genouts(size) + ",%s);\n", ...
                    text.label, labels,callbackname);
                case "Text/text_varPos_printDrawing"
                    [size,labels] = o.checkInputs(text);
                        fprintf(o.fileID,"%s = Text(" + ExportScript.genouts(size) + ");\n", ...
                    text.label, labels);
            end
            o.addLabel(string(text.label));
        end

        function exportdcustomvalue(o,val)
            callbackname = ExportScript.getusercallback(val);
            [size,labels] = o.checkInputs(val);
            fprintf(o.fileID,"%s = CustomValue('%s'," + ExportScript.genouts(size) + ",%s);\n", ...
                val.label, val.label, labels,callbackname);
            o.addLabel(string(val.label));
        end

        function exportEval(o,eval)
            expr = regexprep(functions(eval.callback).function, ...
                    '@\([^)]*\)\((.+)\)','$1');
            expr = regexprep(expr,'\.value','');
            fprintf(o.fileID,"%s = Eval('%s',%s);\n", eval.label, eval.label, expr);
            o.addLabel(string(eval.label));
        end

        function exportdlines(o,line)
            if ExportScript.isCallbackNamed(line,'@(a,b)a.value+(b.value-a.value).*[0;1]') || ...
               ExportScript.isCallbackNamed(line,'@(a,b)a.value+b.value.*[0;1]')
                o.exportLineWithType(line,"Segment");
            elseif ExportScript.isCallbackNamed(line,'@(a,b)a.value+(b.value-a.value).*[-1e8;-1e4;0;1;1e4;1e8]') || ...
                   ExportScript.isCallbackNamed(line,'@(a,b)a.value+b.value.*[-1e8;-1e4;0;1;1e4;1e8]')
                if ExportScript.checkPossiblePerpLine(line); o.exportPerpLinePD(line);
                else; o.exportLineWithType(line,"Line"); end
            elseif ExportScript.isCallbackNamed(line,'@(a,b)a.value+(b.value-a.value).*[0;1;1e4;1e8]') || ...
                   ExportScript.isCallbackNamed(line,'@(a,b)a.value+b.value.*[0;1;1e4;1e8]')
                o.exportLineWithType(line,"Ray"); 
            elseif ExportScript.isCallbackNamed(line,'perpendicular_bisector')
                o.exportLineWithType(line,"PerpendicularBisector"); 
            elseif ExportScript.isCallbackNamed(line,'perpline2point') || ...
                   ExportScript.isCallbackNamed(line,'perpline2segment')
                o.exportLineWithType(line,"PerpendicularLine");
            elseif ExportScript.isCallbackNamed(line,'angle_bisector3') || ...
                   ExportScript.isCallbackNamed(line,'angle_bisector4')
                o.exportLineWithType(line,"AngleBisector");
            elseif ExportScript.isCallbackNamed(line,'segmentseq_concat') || ...
                   ExportScript.isCallbackNamed(line,'SegmentSequence/internalcallback1') || ...
                   ExportScript.isCallbackNamed(line,'SegmentSequence/internalcallback2')
                o.exportSegmentSequence(line);
            elseif ExportScript.isCallbackNamed(line,'mirror_point')
                o.exportMirrorLines(line);
            elseif ExportScript.isCallbackNamed(line,'paraline2segment') || ...
                   ExportScript.isCallbackNamed(line,'paralinewithdist')
                o.exportLineWithType(line,"ParallelLine");
            else
                throw(MException('ExportFigure:exportdlines','Unknown type!'));
            end
        end

        function exportLineWithType(o,line,type)
            [size,labels] = o.checkInputs(line);
            out = "%s = " + type + "('%s'," + ExportScript.genouts(size) + "," + ...
                "'%s',%s,'Color',%s);\n";
            fprintf(o.fileID,out, ...
                line.label, line.label, labels, ...
                line.fig.LineStyle, ...
                string(line.fig.LineWidth), ...
                mat2str(line.fig.Color));
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
            if ExportScript.isCallbackNamed(seq,'segmentseq_concat')
                fprintf(o.fileID,"%s = SegmentSequence('%s'," + ExportScript.genouts(size) + "," + ...
                    "%s,'%s',%s,'Color',%s);\n", ...
                    seq.label, seq.label, labels, ...
                    string(breakEvery), seq.fig.LineStyle, ...
                    string(seq.fig.LineWidth), ...
                    mat2str(seq.fig.Color));
            else
                callbackname = ExportScript.getusercallback(seq);
                fprintf(o.fileID,"%s = SegmentSequence('%s'," + ExportScript.genouts(size) + "," + ...
                    "%s,%s,'%s',%s,'Color',%s);\n", ...
                    seq.label, seq.label, labels, ...
                    callbackname,string(breakEvery), seq.fig.LineStyle, ...
                    string(seq.fig.LineWidth), ...
                    mat2str(seq.fig.Color));
            end
            o.addLabel(string(seq.label));
        end

        function exportPerpLinePD(o,line)
            A = line.inputs{1};
            B = line.inputs{2}.inputs{2};
            o.checkLabel(A);
            o.checkLabel(B);
            fprintf(o.fileID,"%s = PerpendicularLine('%s',%s,%s,'%s',%s,'Color',%s);\n", ...
                line.label, line.label, A.label, B.label, ...
                line.fig.LineStyle, ...
                string(line.fig.LineWidth), ...
                mat2str(line.fig.Color));
            o.addLabel(string(line.label));
        end

        function exportDistance(o,distance)
            depFields = fieldnames(o.go.deps);
            for i = 1:length(depFields)
                dep = o.go.deps.(depFields{i});
                if (isa(dep,'dcircle') && ~isempty(dep.gen_dist) && ...
                   isequal(dep.gen_dist,distance)) || ...
                   (isa(dep,'dcurve') && ...
                   ExportScript.isCallbackNamed(dep,'circ_arc') && ...
                   isequal(dep.inputs{2},distance))
                    return;
                end
            end
            [size,labels] = o.checkInputs(distance);
            fprintf(o.fileID,"%s = Distance('%s'," + ExportScript.genouts(size) + ");\n", ...
            distance.label, distance.label, labels);
            o.addLabel(string(distance.label));
        end

        function exportdscalar(o,scalar)
            if ExportScript.isCallbackNamed(scalar,'dist_point2pointseq') || ...
               ExportScript.isCallbackNamed(scalar,'dist_point2circle') || ...
               ExportScript.isCallbackNamed(scalar,'dist_point2polyline')
                o.exportDistance(scalar);
            elseif ExportScript.isCallbackNamed(scalar,'Scalar/internalcallback')
                callbackname = ExportScript.getusercallback(scalar);
                [size,labels] = o.checkInputs(scalar);
                fprintf(o.fileID,"%s = Scalar('%s'," + ExportScript.genouts(size) +",%s);\n", ...
                    scalar.label, scalar.label, labels, callbackname);
                o.addLabel(string(scalar.label));
            elseif ExportScript.isCallbackNamed(scalar,'base_angle') || ...
                   ExportScript.isCallbackNamed(scalar,'angle_between')
                %skip circarc generated scalars
            else
                o.exportEval(scalar);
            end
        end
    end % private

    methods(Access=private,Static)
        function is = isCallbackNamed(object,name)
            is = contains(functions(object.callback).function,name);
        end

        function ret = checkPossiblePerpLine(line)
            ret = isa(line.inputs{2},'dpoint') && ExportScript.isCallbackNamed(line.inputs{2},'closest');
        end

        function expStr = genouts(size)
            expStr = strjoin(repmat("%s",1,size),',');
        end

        function str = formatValue(value,precision)
            format = '%.' + string(precision) +'f';
            str = "[" + strjoin(compose(format, value),' ') + "]";
        end

        function str = formatmpoly(value,precision)
            format = ['%.' num2str(precision) 'f'];
            rows = arrayfun( ...
                @(i) sprintf([format ' ' format], value(i, :)), ...
                1:size(value, 1), 'UniformOutput', false);
            
            str = ['[', strjoin(strtrim(rows), '; '), ']'];
        end

        function callbackname = getusercallback(object)
            callback = functions(functions(object.callback).workspace{1}.usercallback);
            callbackname = callback.function;
            if ~strcmp(callback.type,'anonymous')
                callbackname = ['@' callbackname];
            else
                %replace workspace variables with actual values
                values = struct2cell(callback.workspace{1});
                labels = fieldnames(callback.workspace{1});
                for i = 1:length(labels)
                    callbackname = regexprep(callbackname, ...
                        [labels{i} '(?=[,|\)])'],num2str(values{i}));
                end
            end
        end

        function str = circleRadiusName(circle)
            if isempty(circle.gen_dist); str = "~";
            else; str = circle.radius.label; end
        end
    end % static private
end

