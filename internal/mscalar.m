classdef mscalar < moveable & scalar_base
    properties
        val
    end
    
methods
    function o = mscalar(parent,label,value)
        fig.bringToFront = [];
        o = o@moveable(parent,label,fig);
        o.val = value;
    end
    function v = value(o)
        v = o.val;
    end

    function updateValue(o,value)
        o.val = value;
        evt.EventName = 'ROIMoved';
        o.update(o.fig,evt);
    end
end
end