classdef mpolygon < moveable
methods
    function o=mpolygon(parent,label,args)
        args = namedargs2cell(args);
        h = drawpolygon(args{:});
        o = o@moveable(parent,label,h);
    end
    function v = value(o)
        v = o.fig.Position([1:end,1],:);
    end
end
end