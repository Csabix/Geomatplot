classdef dlines < dpointlineseq
methods
    function o = dlines(parent,label,inputs,callback,args)
        hidden = strcmp(args.Visible,'off');
        args = namedargs2cell(args);
        fig = line(parent.ax,0,0,args{:});
        o = o@dpointlineseq(parent,label,fig,inputs,callback,hidden);
        addlistener(o.fig,'Hit',@dlines.hit);
    end
end

methods (Static,Hidden)
    function hit(fig,~)
        o = fig.UserData;
        disp('Not implemented yet!');
        %o.parent.addStateData(o);
    end
    
    function [parent,label,inputs,params] = parse_inputs(args,flag,mina,maxa)
        arguments
            args (1,:) cell;       flag (1,:) char   = 'lines';
            mina (1,1) double = 2; maxa (1,1) double = 2;
        end
        [parent,  args]   = Geomatplot.extractGeomatplot(args);   
        [label ,  args]   = parent.extractLabel(args,flag);
        [inputs,  args]   = parent.extractInputs(args,mina,maxa);
        params = dlines.parse_inputs_(args{:});
    end

    function params = parse_inputs_(linespec,linewidth,params,options)
        arguments
            linespec         (1,:) char       {drawing.mustBeLineSpec}        = 'k'
            linewidth        (1,1) double     {mustBePositive}                =  1
            params.LineWidth (1,1) double     {mustBePositive}
            params.LineStyle (1,:) char
            params.Marker    (1,:) char
            params.Color                      {drawing.mustBeColor}
            params.Visible   (1,:) char       {mustBeMember(params.Visible,{'on','off'})} = 'on'
            options.c          (1,1) double    {mustBePositive} % hack, do not intentionally use this name value arg
            options.m          (1,1) double    {mustBePositive} % hack, do not intentionally use this name value arg   
        end
        if isfield(options,'c'); linespec = 'c'; linewidth = options.c; end
        if isfield(options,'m'); linespec = 'm'; linewidth = options.m; end
        if ~isfield(params,'LineWidth'); params.LineWidth = linewidth; end
        params = dlines.applyLineSpec(params,linespec);
    end

    function params = applyLineSpec(params,linespec)
        [~,LineStyle,Marker,Color] = drawing.matchLineSpec(linespec);
        if ~isfield(params,'LineStyle')
            if ~isempty(LineStyle); params.LineStyle = LineStyle; end
        end
        if ~isfield(params,'Marker')
            if ~isempty(Marker);     params.Marker = Marker;      end
        end
        if ~isfield(params,'Color')
            if ~isempty(Color);     params.Color = Color;
            else;                   params.Color = 'k';           end
        end
    end
end
end