classdef mpoint < moveable & point_base
methods
    function o = mpoint(parent,label,args)
        args = namedargs2cell(args);
        h = drawpoint(parent.ax,'Deletable',0,args{:});
        o = o@moveable(parent,label,h);
    end
    function v = value(o)
        v = o.fig.Position;
    end
end
end