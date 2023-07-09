classdef (Abstract) moveable < drawing % with ROI
properties
    deps  % struct mapping label -> dependent class handles 
end
methods
    function o = moveable(parent,label,fig)
        o = o@drawing(parent,label,fig);
        o.parent.movs.(label) = o;
        addlistener(o.fig,'ROIMoved' ,@(~,evt) o.update(evt)); % todo @update ?
        addlistener(o.fig,'MovingROI',@(~,evt) o.update(evt));
    end
    function addCallback(o,dep)
        if ~isfield(o.deps,dep.label)
            o.deps.(dep.label) = dep;
            o.fig.bringToFront;
        end
    end
    function update(o,evt)
        %labels = fieldnames(o.deps);
        values = struct2cell(o.deps);
        for i = 1:length(values)
            h = values{i};
            h.update;
        end
    end
end
end