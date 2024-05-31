classdef dpoint < dependent & point_base
methods
    function o = dpoint(parent,label,inputs,callback,args)
        if nargin < 5
            args.Color='k'; args.MarkerSize=5; args.LabelAlpha=0; args.LabelTextColor='k';
            args.Label=label; args.LabelVisible ='hover'; args.Visible='on';
        end
        hidden = strcmp(args.Visible,'off');
        args = namedargs2cell(args);
        fig = drawPoint("Movable",false,"Position",[0,0],args{:});
        o = o@dependent(parent,label,fig,inputs,callback,hidden);
    end
    function v = value(o)
        v = o.fig.Position;
    end
    function updatePlot(o,pos)
        if ~any(isnan(pos))
            o.fig.Position = pos;
        else
            o.defined = false;
        end
    end
    function update(o,~)
        update@dependent(o);
        %o.labelfig.Position = o.fig.Position;
    end
end
methods (Static)
    function outs = parseOutputs(args)
        if length(args)==1
            outs{1} = args{1}(:)';
        elseif length(args)==2
            outs{1} = [args{1}(:) args{2}(:)];
        else
            error 'Callback has too many outputs.'
        end
    end
end
methods (Static,Hidden)

    function [parent,label,inputs,params] = parse_inputs(args,flag,mina,maxa)
        arguments
            args (1,:) cell;       flag (1,:) char   = 'capital';
            mina (1,1) double = 1; maxa (1,1) double = inf;
        end
        [parent,args] = Geomatplot.extractGeomatplot(args);    
        [label, args] = parent.extractLabel(args,flag);
        [inputs,args] = parent.extractInputs(args,mina,maxa);
        params        = dpoint.parse_inputs_(args{:});
        params.Label  = label;
    end
    
    function params = parse_inputs_(color,markersize,params)
        arguments
            color                            {drawing.mustBeColor}                  = 'k'
            markersize          (1,1) double {mustBePositive}                       = 6
            params.MarkerSize   (1,1) double {mustBePositive}
            params.LabelAlpha   (1,1) double {mustBeInRange(params.LabelAlpha,0,1)} = 0
            params.LabelTextColor            {drawing.mustBeColor}
            params.LineWidth    (1,1) double {mustBePositive}
            params.LabelVisible (1,:) char   {mustBeMember(params.LabelVisible,{'on','off','hover'})}
            params.Visible      (1,:) char   {mustBeMember(params.Visible,{'on','off'})} = 'on'
        end
        params.Color = color;
        if ~isfield(params,'LabelTextColor'); params.LabelTextColor = color; end
        if ~isfield(params,'MarkerSize');     params.MarkerSize = markersize; end
    end

end
end