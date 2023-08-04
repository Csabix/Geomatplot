classdef dpoint < dependent & point_base
methods
    function o = dpoint(parent,label,inputs,callback,args)
        if nargin < 5
            args.Color='k'; args.MarkerSize=6; args.LabelAlpha=0; args.LabelTextColor='k';
            args.Label=label; args.LabelVisible ='hover';
        end
        args = namedargs2cell(args);
        fig = drawpoint('InteractionsAllowed','none',args{:},'Position',[0 0]);
        o = o@dependent(parent,label,fig,inputs,callback);
    end
    function v = value(o)
        v = o.fig.Position;
    end
    function updatePlot(o,pos)
        o.fig.Position = pos;
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

    function [parent,label,inputs,args] = parse_inputs(varargin)
        [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
        [label,varargin] = parent.extractLabel(varargin,'capital');
        [parent,label,inputs,args] = dpoint.parse_inputs_(parent,label,varargin{:});
        inputs = parent.getHandlesOfLabels(inputs);
    end
    
    function [parent,label,inputs,args] = parse_inputs_(parent,label,inputs,color,args)
        arguments
            parent          (1,1) Geomatplot
            label           (1,:) char      {mustBeValidVariableName}
            inputs          (1,:) cell      {drawing.mustBeInputList(inputs,parent)}
            color                           {drawing.mustBeColor}               = 'k'
            args.MarkerSize (1,1) double    {mustBePositive}                    = 7
            args.LabelAlpha (1,1) double    {mustBeInRange(args.LabelAlpha,0,1)}= 0
            args.LabelTextColor             {drawing.mustBeColor}
            args.LineWidth  (1,1) double    {mustBePositive}
        end
        args.Label = label;
        args.Color = color;
        if ~isfield(args,'LabelTextColor'); args.LabelTextColor = color; end
    end

end
end