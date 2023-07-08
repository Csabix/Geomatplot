classdef Geomatplot < handle
properties
	ax (1,1) %matlab.ui.Axes;
	movs % struct mapping label -> movable class handles
	deps % struct mapping label -> dependent class handles 
end
properties
    nextCapitalLabel (1,1) int32 = 0; % 65 = 'A' = 'Z'-25
    nextSmallLabel (1,1) int32 = 0;   % 97 = 'a' = 'z'-25
end
methods
    
    function o = Geomatplot(ax)
        % todo xlim
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
methods (Access = private, Static)
    function l = getNextLabel(index,offset)
        l = char(mod(index,26)+offset);
        i = idivide(index,26);
        if i~=0; l = [l int2str(i)]; end
    end
end
end