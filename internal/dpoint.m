classdef dpoint < dependent & point_base
methods
    function o = dpoint(parent,label,inputs,callback,args)
        if nargin < 5
            args.Color='k'; args.MarkerSize=5; args.LabelAlpha=0; args.LabelTextColor='k';
            args.Label=label; args.LabelVisible ='hover'; args.Visible='on';
        end
        hidden = strcmp(args.Visible,'off');
        args = namedargs2cell(args);
        fig = drawpoint(parent.ax,args{:},'Position',[0 0]);
        o = o@dependent(parent,label,fig,inputs,callback,hidden);
        addlistener(o.fig,'ROIMoved'  ,@dpoint.move);
        addlistener(o.fig,'MovingROI' ,@dpoint.move);
        addlistener(o.fig,'ROIClicked',@dependent.hit);
    end
    function updatePlot(o,pos)
        if ~any(isnan(pos))
            o.fig.Position = pos;
        else
            o.defined = false;
        end
    end
end
methods (Static)
    
    function move(fig,evt)
        fig.Position = evt.PreviousPosition;
    end

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