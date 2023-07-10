classdef (Abstract) drawing < handle
properties
	parent  (1,1) Geomatplot
	label	(1,:) char % indetifier
	fig		% plot handle to ROI or matlab plot
end
methods
    function o = drawing(parent,label,fig)
        o.parent = parent;
        o.label = label;
        o.fig = fig;
    end
end
methods (Abstract)
	value(o) % current value: positions matrix or a struct
    update(o,~)
end
methods (Access=public,Static)

    function x = findCurrentGeomatplot(x)
        if isempty(x)
            x = gca;
        end
        if isa(x,'matlab.ui.Figure')
            if isempty(x.Children)
                x = axes(x);
            else
                x = x.Chilren(1);
            end
        end
        if isa(x,'matlab.graphics.axis.Axes')
            x = x.UserData;
        end
        if isempty(x)
            x = Geomatplot;
        end
        if ~isa(x,'Geomatplot')
            error 'Geomatplot not found, wrong argument'
        end
    end

    function b = isColorName(x)
        shorcolnames = 'rgbcmykw';
        longcolnames = ["red","green","blue","cyan","magenta","yellow","black","white"];
        b = isnumeric(x) && (length(x)==3) ||...
            ischar(x) && (length(x)==1) && any(x==shorcolnames) || ...
            (isstring(x) || ischar(x)) && any(strcmp(x,longcolnames));
    end
    
    function b = isLabelList(x)
        if iscellstr(x)
            b = true;
        elseif ~iscell(x)
            b = false;
        else
            b = true;
            for i = 1:length(x)
                b = b && (isa(x{i},'drawing') || ischar(x) || isstring(x));
            end
        end
    end

    function args = struct2arglist(s)
        ns = fieldnames(s);
        args(1:2:2*length(ns)) = ns;
        args(2:2:2*length(ns)) = struct2cell(s);
    end

    function labels = getHandlesOfLabels(parent,x)
        labels = cell(1,length(x));
        for i=1:length(x)
            if isa(x{i},'drawing')
                labels{i} = x{i};
            else
                labels{i} = parent.getHandle(x{i});
            end
        end
    end

    function b = isLabelPatternMatching(labels,pattern)
        if length(labels) ~= length(pattern)
            b = false;
        else
            b = true;
            for i = 1:length(labels)
                b = b && isa(labels{i},pattern{i});
            end            
        end
    end
    
    function [b,ms] = matchLineSpec( spec )
        ms = cell(1,3);
        if strlength(spec) == 0
            b = false;
            return;
        end
        exs = cell(1,3);
        exs{1} = '^(-[-.]?|:|\.-)';
        exs{2} = '^([o+*.x_|^v><]|s(q(u(a(re?)?)?)?)?|d(i(a(m(o(nd?)?)?)?)?)?|p(e(n(t(a(g(r(am?)?)?)?)?)?)?)?|h(e(x(a(g(r(am?)?)?)?)?)?)?)';
        exs{3} = '^(r(ed?)?|g(r(e(en?)?)?)?|b(l(ue?)?)?|c(y(an?)?)?|m(a(g(e(n(ta?)?)?)?)?)?|y(e(l(l(ow?)?)?)?)?|(blac)?k|bla|blac|w(h(i(te?)?)?)?)';

        for k = 1:3
            for i=1:3
                if exs{i} == 0
                    continue;
                end
                m = regexp(spec,exs{i},'match','once');
                if size(m,1) == 1
                    ms{i} = m;
                    exs{i} = 0;
                    spec = extractAfter(spec,strlength(m));
                    break;
                end
            end
            if strlength(spec) == 0
                break;
            end
        end
        b = strlength(spec) == 0;
    end
end
end