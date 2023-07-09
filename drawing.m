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
    addCallback(o,callback)
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
end
end