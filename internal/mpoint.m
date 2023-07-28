classdef mpoint < moveable & point_base
methods
    function o = mpoint(parent,label,args)
        args = namedargs2cell(args);
        h = drawpoint('Deletable',0,args{:});
        o = o@moveable(parent,label,h);
    end
    function v = value(o)
        v = o.fig.Position;
    end
    function c=minus(a,b)
        c = dvector.operator(a,b,@minus,'mpoint','dvector',@dpoint,'mpoint','mpoint',@dvector);
    end
    function c=plus(a,b)
        c = dvector.operator(a,b,@minus,'mpoint','dvector',@dpoint);
    end
end
end