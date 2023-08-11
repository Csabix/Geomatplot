classdef Geomatplot < handle & matlab.mixin.CustomDisplay
properties
	ax (1,1) %matlab.ui.Axes;
	movs % struct mapping label -> movable class handles
	deps % struct mapping label -> dependent class handles 
end
properties (Hidden)
    nextCapitalLabel (1,1) int32  = 0;      % 65 = 'A' = 'Z'-25
    nextSmallLabel   (1,1) int32  = 0;      % 97 = 'a' = 'z'-25
    nextOtherLabels  (1,1) struct = struct;
end
    
methods (Access = public)
    
    function o = Geomatplot(ax)
        % todo xlim
        addpath internal\ examples\
        if nargin == 0
            o.ax = gca;
        elseif isa(ax,'matlab.ui.Figure')
            if isempty(ax.Children)
                o.ax = axes(ax);
            else
                o.ax = ax.Children(1);
            end
        elseif isa(ax,'matlab.ui.Axes')
            o.ax = ax;
        end
        axis(o.ax,'equal'); axis(o.ax,'manual');
        o.ax.Interactions = [panInteraction zoomInteraction]; % disableDefaultInteractivity(o.ax);
        o.movs = struct; o.deps = struct;
        o.ax.UserData = o;
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

end % public

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

    function [inputs,args]=extractInputs(o,args,mina,maxa)
        arguments
            o (1,1) Geomatplot; args (1,:) cell; mina (1,1) double = 0; maxa (1,1) double = inf;
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
                elseif ~isa(h,'drawing')
                    throwAsCaller(MException('extractInputs:invalidType','The input label is of invalid type or size.'));
                end
            end
            args = args(2:end);
        else
            for i=1:length(args)
                if ~isa(args{i},'drawing'); i=i-1; break; end %#ok<FXSET> 
                if args{i}.parent ~= o
                    throwAsCaller(MException('extractInputs:differentParent','The input has a different Geomatplot than expected.\n(Sometimes it is a one-off, try running your code again)'));
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
                    || isa(args{1},'point_base'))
                position = args{1};
                args = args(2:end);
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

        str = strings(mnum+dnum+1,6);
        labels = fieldnames(o.movs); values = struct2cell(o.movs);
        str(1,:) = [" label", "type", "runtime", "mean pos", "labels", "callback"];
        for i=1:mnum
            v = values{i};vv = v.value;
            str(i+1,1:4) = [''''+string(labels{i})+'''', string(class(v)), [num2str(v.runtime*1000,'%.2fms')], num2str(mean(vv,1),'[%.2f %.2f]')];
        end
        labels = fieldnames(o.deps); values = struct2cell(o.deps);
        for i=1:dnum
            v = values{i};
            if isa(v,'dscalar')
                meanstr = num2str(mean(v.value,1),'%.4f');
            else
                if isa(v,'dtext')
                    vv = v.fig.Position(1:2);
                else
                    vv = v.value;
                end
                meanstr = num2str(mean(vv,1),'[%.2f %.2f]');
            end
            ls = cell(1,length(v.inputs));
            for j=1:length(v.inputs)
                ls{j} = v.inputs{j}.label;
            end
            str(i+1+mnum,:) = [''''+string(labels{i})+'''', string(class(v)), [num2str(v.runtime*1000,'%.2fms')], meanstr,...
                                join(ls,','), func2str(v.callback)];
        end
        str(:,1) = pad(str(:,1),'left');
        str(:,2) = pad(str(:,2),'right');
        str(:,3) = pad(str(:,3),'both');
        str(:,4) = pad(str(:,4),'both');
        str(:,5) = pad(str(:,5),'left');
        str(:,6) = pad(str(:,6),'right');
        str = str(:,1) + ' : ' + str(:,2) + ' ' + str(:,3) + ' ' + str(:,4) + ' | ' + str(:,5) +' : ' + str(:,6);
        str = join(str,"\n",1);
        str = o.getHeader(mnum,dnum) + str+'\n'+matlab.mixin.CustomDisplay.getDetailedFooter(o);
        fprintf(str);
    end

end

methods (Static, Access = public, Hidden)

    function parent = findCurrentGeomatplot(parent)
        if isempty(parent); parent = gca; end
        if isa(parent,'matlab.ui.Figure')
            if isempty(parent.Children)
                parent = axes(parent);
            else
                parent = parent.Chilren(1);
            end
        end
        if isa(parent,'matlab.graphics.axis.Axes')
            parent = parent.UserData;
        end
        if isempty(parent); parent = Geomatplot; end
    end

    function [parent, args] = extractGeomatplot(args)
        if ~isempty(args) && isscalar(args{1}) && ~isnumeric(args{1}) && (isa(args{1},'Geomatplot') || ishandle(args{1}))
            parent = args{1};
            args = args(2:end);
        else
            parent = [];
        end
        parent = Geomatplot.findCurrentGeomatplot(parent);
        if ~isa(parent,'Geomatplot')
            eidType = 'extractGeomatplot:noGeomatplot';
            msgType = 'Geomatplot not found, probably wrong argument.';
            throwAsCaller(MException(eidType,msgType));
        end
    end

end % static public hidden

end