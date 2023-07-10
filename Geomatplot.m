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
end
methods (Hidden)
    function l = getNextCapitalLabel(o)
        l = Geomatplot.getNextLabel(o.nextCapitalLabel,65); % 'A'
        o.nextCapitalLabel = o.nextCapitalLabel + 1;
        if isfield(o.movs,l) || isfield(o.deps,l); l = o.getNextCapitalLabel; end
    end

    function l = getNextSmallLabel(o)
        l = Geomatplot.getNextLabel(o.nextSmallLabel,97); % 'a'
        o.nextSmallLabel = o.nextSmallLabel + 1;
        if isfield(o.movs,l) || isfield(o.deps,l); l = o.getNextSmallLabel; end
    end
end
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
            ls = cell(1,length(v.labels));
            for j=1:length(v.labels)
                ls{j} = v.labels{j}.label;
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
end
methods (Access = private, Static)
    function l = getNextLabel(index,offset)
        l = char(mod(index,26)+offset);
        i = idivide(index,26);
        if i~=0; l = [l int2str(i)]; end
    end
end
end