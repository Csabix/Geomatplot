classdef dpointseq < dpointlineseq
methods
    function o = dpointseq(parent,label,labels,callback,s)
        parent.ax.NextPlot ='add';
        args = {'MarkerEdgeColor',s.SMarkerEdgeColor,'MarkerFaceColor',s.SMarkerFaceColor,'LineWidth',s.SLineWidth};
        fig = scatter(parent.ax,0,0,s.SMarkerSize,s.SMarkerColor,args{:});
        o = o@dpointlineseq(parent,label,fig,labels,callback);
    end
    function v = value(o,i)
        if nargin == 2
            v = [o.fig.XData(i) o.fig.YData(i)];
        else
            v = [o.fig.XData(:) o.fig.YData(:)];
        end
    end
end
end