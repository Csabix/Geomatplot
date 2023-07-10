classdef dpointseq < dpointlineseq
methods
    function o = dpointseq(parent,label,labels,callback,args)
        o = o@dpointlineseq(parent,label,labels,callback);
        ret = o.call;
        parent.ax.NextPlot ='add';
        o.fig = scatter(parent.ax,ret{1},ret{2},args{:});
        o.fig.UserData = o;
    end
end
end