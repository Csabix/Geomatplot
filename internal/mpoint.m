classdef mpoint < moveable & point_base
methods
    function o = mpoint(parent,label,args)
        h = drawpoint(args{:});
        o = o@moveable(parent,label,h);
    end
    function v = value(o)
        v = o.fig.Position;
    end
end
end