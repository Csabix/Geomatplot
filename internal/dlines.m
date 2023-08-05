classdef dlines < dpointlineseq
methods
    function o = dlines(parent,label,inputs,linespec,callback,args,varargin)
        [~,LineStyle,Marker,Color] = drawing.matchLineSpec(linespec);
        if ~isempty(LineStyle); args.LineStyle = LineStyle; end
        if ~isempty(Marker);    args.Marker    = Marker;    end
        if ~isempty(Color);     args.Color     = Color;     end
        args = namedargs2cell(args);
        fig = line(parent.ax,0,0,args{:});
        o = o@dpointlineseq(parent,label,fig,inputs,callback);
    end
end

methods (Static,Hidden)
    function [parent,label,inputs,linespec,params] = parse_inputs(args,flag,mina,maxa)
        arguments
            args (1,:) cell;       flag (1,:) char   = 'small';
            mina (1,1) double = 2; maxa (1,1) double = 2;
        end
        [parent,  args]   = Geomatplot.extractGeomatplot(args);   
        [label ,  args]   = parent.extractLabel(args,flag);
        [inputs,  args]   = parent.extractInputs(args,mina,maxa);
        [linespec,params] = dlines.parse_inputs_(args{:});
    end

    function [linespec,args] = parse_inputs_(linespec,args)
        arguments
            linespec       (1,:) char       {drawing.mustBeLineSpec}        = 'k-'
            args.LineWidth (1,1) double     {mustBePositive}                = 1.5
            args.LineStyle (1,:) char
            args.Marker    (1,:) char
            args.Color                      {drawing.mustBeColor}           = 'k'
        end
    end
end
end