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

methods (Static,Hidden)
    function [parent,label,inputs,linespec,args] = parse_inputs(varargin)
        [parent,varargin] = Geomatplot.extractGeomatplot(varargin);   
        [label,varargin] = parent.extractLabel(varargin,'small');
        [parent,label,inputs,linespec,args] = dlines.parse_inputs_(parent,label,varargin{:});
        inputs = parent.getHandlesOfLabels(inputs);
    end

    function [parent,label,inputs,linespec,args] = parse_inputs_(parent,label,inputs,linespec,args)
        arguments
            parent         (1,1) Geomatplot
            label          (1,:) char       {mustBeValidVariableName}
            inputs         (1,:) cell       {drawing.mustBeInputList(inputs,parent)}
            linespec       (1,:) char       {drawing.mustBeLineSpec}        = 'k-'
            args.LineWidth (1,1) double     {mustBePositive}                = 1.5
            args.LineStyle (1,:) char
            args.Marker    (1,:) char
            args.Color                      {drawing.mustBeColor}           = 'k'
        end
    end
end
end