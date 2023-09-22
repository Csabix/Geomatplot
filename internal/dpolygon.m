classdef dpolygon < dpointlineseq
methods
    function o = dpolygon(parent,label,inputs,callback,args)
        C = args.Color;
        args = rmfield(args,'Color');
        args = namedargs2cell(args);
        parent.ax.NextPlot ='add';
        fig = fill(parent.ax,0,0,C,args{:});
        o = o@dpointlineseq(parent,label,fig,inputs,callback);
    end
end
methods (Static,Hidden)
    
end
end