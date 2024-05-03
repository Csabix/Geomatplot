classdef dpointseq < dpointlineseq
methods
    function o = dpointseq(parent,label,labels,callback,s,hidden)
        %parent.ax.NextPlot ='add';
        %sz = s.MarkerSize; c = s.MarkerColor; mkr = s.MarkerSymbol;
        %args = namedargs2cell(rmfield(s,{'MarkerSize','MarkerColor','MarkerSymbol'}));
        %fig = scatter(parent.ax,0,0,sz,c,mkr,args{:});
        args = namedargs2cell(s);
        fig = Scatter(args{:});
        o = o@dpointlineseq(parent,label,fig,labels,callback,hidden);
    end
    function v = value(o,i)
        if nargin == 2
            %v = [o.fig.XData(i) o.fig.YData(i)];
            v = o.fig.Position(i,:);
        else
            v = o.fig.Position;
        end
    end
end
end