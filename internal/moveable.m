classdef (Abstract) moveable < drawing % with ROI
properties
    deps  % struct mapping label -> dependent class handles 
end
methods
    function o = moveable(parent,label,fig)
        o = o@drawing(parent,label,fig);
        o.parent.movs.(label) = o;
        o.fig.UserData = o;
        addlistener(o.fig,'ROIMoved' ,@moveable.update); % todo @update ?
        addlistener(o.fig,'MovingROI',@moveable.update);
    end
    function addCallback(o,dep)
        o.deps.(dep.label) = dep;
        o.fig.bringToFront;
    end
end
methods (Static)
    function update(fig,evt)
        switch evt.EventName
            case 'ROIMoved'
                detail_level = 1;
            case 'MovingROI'
                detail_level = 0.25;
        end
        values = struct2cell(fig.UserData.deps);
        for i = 1:length(values)
            values{i}.update(detail_level);
        end
    end
end
end