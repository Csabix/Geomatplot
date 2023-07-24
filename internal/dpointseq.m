classdef dpointseq < dpointlineseq
methods
    function o = dpointseq(parent,label,labels,callback,args)
        o = o@dpointlineseq(parent,label,labels,callback);
        parent.ax.NextPlot ='add';
        args = namedargs2cell(args);
        o.fig = scatter(parent.ax,0,0,args{:});
        o.fig.UserData = o;
        o.update(1);
    end
end
end