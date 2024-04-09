classdef mpolygon < moveable & polygon_base
methods
    function o=mpolygon(parent,label,args)
        args = namedargs2cell(args);
        h = drawpolygon(args{:});
        o = o@moveable(parent,label,h);
    end
% TODO .value not consistent with dpolygon
    function v = value(o)
        v = o.fig.Position([1:end,1],:);
    end
    function s = string(o)
        s = string@moveable(o,2) + " n=" + num2str(size(o.value,1));
    end
end
end