classdef Geomatplot < handle & matlab.mixin.CustomDisplay
properties
	ax (1,1) %matlab.ui.Axes;
	movs % struct mapping label -> movable class handles
	deps % struct mapping label -> dependent class handles 
end
properties (Hidden)
    nextCapitalLabel (1,1) int32 = 0; % 65 = 'A' = 'Z'-25
    nextSmallLabel (1,1) int32 = 0;   % 97 = 'a' = 'z'-25
end

methods (Access = public)
    
    function o = Geomatplot(ax)
        % todo xlim
        addpath internal\
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
        % todo? buildMap?
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

    function varargout = subsref(o,subs)
        switch subs(1).type
            case '()'
                if length(o) > 1 || length(subs) > 1 || length(subs.subs) > 1 || ~ischar(subs.subs{1})
                    error 'Not supported indexing';
                end                
                varargout = {o.getElement(subs.subs{1})};
            otherwise   
              [varargout{1:nargout}]=builtin('subsref',o,subs);
        end
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
        if ~isempty(args) && (size(args{1},1)==1 && ischar(args{1}) || isStringScalar(args{1}) )
            label = args{1};
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
            args = args(2:end);
        else
            label = o.getNextLabel(flag);
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
            v = values{i};vv = v.value;
            ls = cell(1,length(v.inputs));
            for j=1:length(v.inputs)
                ls{j} = v.inputs{j}.label;
            end
            str(i+1+mnum,:) = [''''+string(labels{i})+'''', string(class(v)), [num2str(v.runtime*1000,'%.2fms')], num2str(mean(vv,1),'[%.2f %.2f]'),...
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
                error 'Invalid flag'
        end
        if o.isLabel(l); l = o.getNextLabel(flag); end
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