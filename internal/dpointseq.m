classdef dpointseq < dpointlineseq
methods
    function o = dpointseq(parent,label,labels,callback,s)
        o = o@dpointlineseq(parent,label,labels,callback);
        parent.ax.NextPlot ='add';
        args = {'MarkerEdgeColor',s.SMarkerEdgeColor,'MarkerFaceColor',s.SMarkerFaceColor,'LineWidth',s.SLineWidth};
        o.fig = scatter(parent.ax,0,0,s.SMarkerSize,s.SMarkerColor,args{:});
        o.fig.UserData = o;
        o.update(1);
    end
end
end