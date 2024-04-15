classdef Geomatplot < handle & matlab.mixin.CustomDisplay
properties
	ax (1,1) %matlab.ui.Axes;
	movs % struct mapping label -> movable class handles
	deps % struct mapping label -> dependent class handles 
    clickData % contains the clicked objects
    acceptFcn % accept function callback
    drawFcn % draw function callback
    errorFcn % error function callback
end
properties (Hidden)
    nextCapitalLabel (1,1) int32  = 0;      % 65 = 'A' = 'Z'-25
    nextSmallLabel   (1,1) int32  = 0;      % 97 = 'a' = 'z'-25
    nextOtherLabels  (1,1) struct = struct;
end
    
methods (Access = public)
    
    function o = Geomatplot(ax)
        folder = mfilename('fullpath');
        folder = folder(1:end-length(mfilename));
        addpath([folder '/internal/'], [folder '/examples/']);
        if nargin == 0
            o.ax = gca;
        elseif isa(ax,'matlab.ui.Figure')
            if isempty(ax.Children)
                o.ax = axes(ax);
            else
                o.ax = ax.Children(1);
            end
        elseif isa(ax,'matlab.graphics.axis.Axes')
            o.ax = ax;
        end
        if isempty(o.ax.UserData)
            if isa(o.ax, 'matlab.ui.control.UIAxes')
                pbaspect(o.ax, [1 1 1]);
                o.ax.XLimMode = 'manual';
                o.ax.YLimMode = 'manual';
            else; axis(o.ax,'equal'); axis(o.ax,'manual'); 
            end
            o.ax.Interactions = [panInteraction zoomInteraction]; % disableDefaultInteractivity(o.ax);
            o.movs = struct; o.deps = struct;
            o.ax.UserData = o;
            addlistener(o.ax,'Hit',@o.emptySpace);
        else % workaround hack for matlab wtf
            assert(isa(o.ax.UserData,'Geomatplot'));
            o = o.ax.UserData;
        end
    end

    function h = getHandle(o,label)
        if isfield(o.movs,label)
            h = o.movs.(label);
        elseif isfield(o.deps,label)
            h = o.deps.(label);
        else
            error(['label ''' label ''' not found']);
        end
    end
    
    function v = getElement(o,label)
        h = o.getHandle(label);
        v = h.value();
    end

    function b = isLabel(o,l)
        b = isfield(o.movs,l) || isfield(o.deps,l);
    end

    function addHandlerFcns(o,acceptFcn,drawFcn,errorFcn)
        o.acceptFcn = acceptFcn;
        o.drawFcn = drawFcn;
        o.errorFcn = errorFcn;
        o.clickData = [];
    end

    function pushData(o,value)
        if isempty(o.acceptFcn); return; end
        o.clickData = [o.clickData, {value}];
        o.checkData();
    end

    function checkData(o)
        switch o.acceptFcn(o.clickData)
            case 1 %Accept state
                o.drawFcn(o.clickData);
                o.clickData = [];
            case -1 %Error state
                o.errorFcn(); %Temporary
                o.clickData = [];
        end
    end
end % public

methods(Access = public, Static)
    
    function summary(o)
        if nargin == 0; o = Geomatplot.findCurrentGeomatplot; end
        disp(o);
    end

    function [M,D] = runtimes(o)
        if nargin ==0; o = Geomatplot.findCurrentGeomatplot; end
        values = struct2cell(o.movs); labels = fieldnames(o.movs);
        M = NaN(length(values),2);
        for i=1:length(values)
            M(i,:) = [values{i}.move_total_time,values{i}.stop_total_time];
        end
        M = num2cell(M*1000,1);
        vnames = ["move_total","stop_total"];     
        M = table(M{:},'RowNames',labels,'VariableNames',vnames);
        
        if nargout <2; return; end

        values = struct2cell(o.deps);
        labels = fieldnames(o.deps);
        D = NaN(length(values),12);
        for i=1:length(values)
            D(i,:) = values{i}.runtimes;
        end
        D = num2cell(D*1000,1);
        vnames = ["last_total","last_callb","last_parse","last_plots",...
                  "move_total","move_callb","move_parse","move_plots",...
                  "stop_total","stop_callb","stop_parse","stop_plots"];     
        D = table(D{:},'RowNames',labels,'VariableNames',vnames);
    end
end

methods (Access = public, Hidden)

    function handles = getHandlesOfLabels(o,x)
        handles = cell(1,length(x));
        for i=1:length(x)
            if isa(x{i},'drawing')
                handles{i} = x{i};
            else
                handles{i} = o.getHandle(x{i});
            end
        end
    end

    function [label,args] = extractLabel(o,args,flag)
        [label,args] = drawing.extractText(args);
        if ~isempty(label)
            if ~isvarname(label)
                eidType = 'extractLabel:notVariableName';
                msgType = ['Label ''' label ''' is not a valid variable name.'];
                throwAsCaller(MException(eidType,msgType));
            end
            if o.isLabel(label)
                eidType = 'extractLabel:labelAleadyExists';
                msgType = ['Label ''' label ''' already exists.'];
                throwAsCaller(MException(eidType,msgType));
            end
        else
            if strcmp(flag,'none')
                label = [];
            else
                label = o.getNextLabel(flag);
            end
        end
    end

    function [labels,args] = extractMultipleLabels(o,args,flag)
        if isempty(args) || (size(args{1},1)==1 && ischar(args{1})) || isStringScalar(args{1})
            try
                [labels{1},args] = o.extractLabel(args,flag);
            catch ME
                if strcmp(ME.identifier,'extractLabel:labelAleadyExists')
                    labels{1} = o.getNextLabel(flag);
                else
                    rethrow(ME);
                end
            end
        elseif isreal(args{1}) && isfinite(args{1}) && args{1}==floor(args{1}) && args{1} >= 0
            labels = cell(1,args{1});
            for i=1:args{1}
                labels{i} = o.getNextLabel(flag);
            end
            args = args(2:end);
        elseif iscell(args{1})
            ls = args{1}; b = true;
            for i=1:length(ls)
                if ~(((size(ls{i},1)==1 && ischar(ls{i})) || isStringScalar(ls{i})) && ~o.isLabel(ls{i}))
                    b = false; break;
                end
            end
            if b
                labels = args{1};
                args = args(2:end);
            else
                labels{1} = o.getNextLabel(flag);
            end
        else
            labels{1} = o.getNextLabel(flag);
        end
    end

    function [inputs,args] = extractInputs(o,args,mina,maxa,evalExpressions)
        arguments
            o (1,1) Geomatplot
            args (1,:) cell
            mina (1,1) double = 0
            maxa (1,1) double = inf
            evalExpressions (1,1) logical = true
        end
        if isempty(args); inputs = {}; return; end
        if isa(args{1},'cell')
            inputs = args{1};

            for i = 1:length(inputs)
                h = inputs{i};
                if size(h,1)==1 && ischar(h) || isStringScalar(h)
                    if ~isvarname(h)
                        throwAsCaller(MException('extractInputs:notVariableName',['The input label ''' h ''' is not a valid variable name.']));
                    end
                    if ~o.isLabel(h)
                        throwAsCaller(MException('extractInputs:labelNotFound',['The input label ''' h ''' does not exist.']));
                    end
                    inputs{i}=o.getHandle(h);
                elseif ~isa(h,'drawing') && ~isa(h,'expression_base')
                    throwAsCaller(MException('extractInputs:invalidType','The input label is of invalid type or size.'));
                end
            end
            args = args(2:end);
        else
            for i=1:length(args)
                ai = args{i};
                if ~isa(ai,'drawing') && ~isa(ai,'expression_base')
                    i=i-1;       %#ok<FXSET> 
                    break;
                end
                if ai.parent ~= o
                    throwAsCaller(MException('extractInputs:differentParent','The input has a different Geomatplot than expected.\n(Sometimes it is a one-off, try running your code again)'));
                end
                if evalExpressions && isa(ai,'expression_base')
                    args{i} = ai.eval();
                end
            end
            inputs = args(1:i);
            args = args(i+1:end);
        end
        if length(inputs)<mina || length(inputs)>maxa
            throwAsCaller(MException('extractInputs:wrongNumberOfInputs','Invalid number of input geomatplot arguments.'));
        end
    end
    
    % [0,1] or {'A'} or A (point_base)
    function [position,args] = extractPoint(o,args)
        % a) const position
        [position,args] = drawing.extractPosition(args);
        % b) cell with one label or point handle
        if isempty(position)
            if ~isempty(args) && (iscellstr(args{1}) && length(args{1})==1 ...
                    || iscell(args{1}) && length(args{1})==1 && isstring(args{1}{1}) ...
                    || isa(args{1},'point_base') || isa(args{1},'expression_base'))
                position = args{1};
                args = args(2:end);
                if isa(position,'expression_base')
                    position = position.eval();
                end
                if iscell(position)
                    position = o.getHandle(position{1});
                end
            else
                throw(MException('Text:notPosition','Couldn''t parse position argument'));
            end
        end
    end
    
    function l = getNextLabel(o,flag)
        function l = convert(index,offset)
            l = char(mod(index,26)+offset);
            i = idivide(index,26);
            if i~=0; l = [l int2str(i)]; end
        end
        switch flag
            case 'small'
                l = convert(o.nextSmallLabel,97); % 'a'
                o.nextSmallLabel = o.nextSmallLabel + 1;
            case 'capital'
                l = convert(o.nextCapitalLabel,65); % 'A'
                o.nextCapitalLabel = o.nextCapitalLabel + 1;
            otherwise
                if ~isfield(o.nextOtherLabels,flag)
                    o.nextOtherLabels.(flag) = 1;
                else
                    o.nextOtherLabels.(flag) = o.nextOtherLabels.(flag) + 1;
                end
                l = [flag int2str(o.nextOtherLabels.(flag))];
        end
        if o.isLabel(l); l = o.getNextLabel(flag); end
    end

end % public hidden

methods (Access = protected)
    function emptySpace(o,~,evt)
            raw.x = evt.IntersectionPoint(1);
            raw.y = evt.IntersectionPoint(2);
            o.pushData(raw);
    end
    function head = getHeader(o,mnum,dnum)
        if nargin == 1
            mnum = length(fieldnames(o.movs));
            dnum = length(fieldnames(o.deps));
        end
        name = matlab.mixin.CustomDisplay.getClassNameForHeader(o);
        head = sprintf('%s with %d movable and %d dependent plots:\n',name,mnum,dnum);
    end
    function displayScalarObject(o)
        mnum = length(fieldnames(o.movs));
        dnum = length(fieldnames(o.deps));

        str = strings(mnum+dnum+1,5);
        labels = fieldnames(o.movs); values = struct2cell(o.movs);
        str(1,:) = [" label", "type", "move/stop time", "value/mean pos", "callback"];
        for i=1:mnum
            v = values{i};
            meanstr = string(v);
            timestr = num2str([v.move_total_time,v.stop_total_time]*1000,'%.2fms/%.2fms');
            str(i+1,1:4) = [''''+string(labels{i})+'''', string(class(v)), timestr, meanstr];
        end
        labels = fieldnames(o.deps); values = struct2cell(o.deps);
        for i=1:dnum
            v = values{i};
            meanstr = string(v);
            timestr = num2str([v.move_total_time,v.stop_total_time]*1000,'%.2fms/%.2fms');
            ls = v.getCallbackStr;
            str(i+1+mnum,:) = [''''+string(labels{i})+'''', string(class(v)), timestr , meanstr, ls];
        end
        str(:,1) = pad(str(:,1),'left');
        str(:,2) = pad(str(:,2),'right');
        str(:,3) = pad(str(:,3),'both');
        str(:,4) = pad(str(:,4),'both');
        str(:,5) = pad(str(:,5),'right');
        %str(:,6) = pad(str(:,6),'right');
        str = str(:,1) + ' : ' + str(:,2) + ' ' + str(:,3) + ' ' + str(:,4) + ' | ' + str(:,5);
        str = join(str,"\n",1);
        str = o.getHeader(mnum,dnum) + str+'\n'+matlab.mixin.CustomDisplay.getDetailedFooter(o);
        fprintf(str);
    end

end

methods (Static, Access = public, Hidden)

    function parent = findCurrentGeomatplot(parent)
        if nargin == 0 || isempty(parent); parent = gca; end
        if isa(parent,'matlab.ui.Figure')
            if isempty(parent.Children)
                parent = axes(parent);
            else
                parent = parent.Children(1);
            end
        end
        if isa(parent,'matlab.graphics.axis.Axes')
            parent = parent.UserData;
        end
    end

    function [parent, args] = extractGeomatplot(args)
        if ~isempty(args) && isscalar(args{1}) && ~isnumeric(args{1}) && (isa(args{1},'Geomatplot') || ishandle(args{1}))
            parent = args{1};
            args = args(2:end);
        else
            parent = [];
        end
        current = Geomatplot.findCurrentGeomatplot(parent);
        if isempty(current)
            if isempty(parent); parent = Geomatplot;
            else; parent = Geomatplot(parent); end
        else
            parent = current;
        end
        if ~isa(parent,'Geomatplot')
            eidType = 'extractGeomatplot:noGeomatplot';
            msgType = 'Geomatplot not found, probably wrong argument.';
            throwAsCaller(MException(eidType,msgType));
        end
    end

end % static public hidden

end