classdef dpointseq < dpointlineseq
methods
    function o = dpointseq(parent,label,labels,callback,s,hidden)
        parent.ax.NextPlot ='add';
        sz = s.MarkerSize; c = s.MarkerColor; mkr = s.MarkerSymbol;
        args = namedargs2cell(rmfield(s,{'MarkerSize','MarkerColor','MarkerSymbol'}));
        fig = scatter(parent.ax,0,0,sz,c,mkr,args{:});
        o = o@dpointlineseq(parent,label,fig,labels,callback,hidden);
        % todo addlistener hit?
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