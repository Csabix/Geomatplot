classdef dlines < dpointlineseq
methods
    function o = dlines(parent,label,inputs,linespec,callback,args,varargin)
        o = o@dpointlineseq(parent,label,inputs,callback);
        %ret = o.call(varargin{:});
        [~,LineStyle,Marker,Color] = drawing.matchLineSpec(linespec);
        if ~isempty(LineStyle); args.LineStyle = LineStyle; end
        if ~isempty(Marker);    args.Marker    = Marker;    end
        if ~isempty(Color);     args.Color     = Color;     end
        args = namedargs2cell(args);
        o.fig = line(o.parent.ax,0,0,args{:});
        o.fig.UserData = o;
        o.update(1);
    end
end
end