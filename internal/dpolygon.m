classdef dpolygon < dpointlineseq & polygon_base
methods
    function o = dpolygon(parent,label,inputs,callback,args)
        C = args.Color;
        args = rmfield(args,'Color');
        args = namedargs2cell(args);
        parent.ax.NextPlot ='add';
        fig = fill(parent.ax,0,0,C,args{:});
        hidden = false;
        o = o@dpointlineseq(parent,label,fig,inputs,callback,hidden);
        addlistener(o.fig,'Hit',@dependent.hit);
    end
end

% TODO .value not consistent with mpolygon
end