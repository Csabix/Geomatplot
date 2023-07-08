classdef mpoint < moveable
methods
    function o = mpoint(parent,label,args)
        o = o@moveable(parent,label);
        o.fig = drawpoint(args{:});
    end
    function v = value(o)
        v = o.fig.Position;
    end
end
end