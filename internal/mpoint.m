classdef mpoint < moveable & point_base
methods
    function o = mpoint(parent,label,args)
        args = namedargs2cell(args);
        h = drawpoint(parent.ax,args{:},'Deletable',0);
        o = o@moveable(parent,label,h);
    end
end
end