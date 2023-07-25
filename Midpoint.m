function h = Midpoint(varargin)

    [parent,label,inputs,args] = parse(varargin{:});
    callback = @(varargin) mean(vertcat(varargin{:}));
    for i = 1:length(inputs)
        l = inputs{i};
        if isa(l,'dcurve') || isa(l,'dimage')
            eidType = 'Midpoint:invalidInput';
            msgType = 'The input drawing cannot be of this type.';
            throw(MException(eidType,msgType));
        end
    end
    h = dpoint(parent,label,inputs,callback,args);
    
end

function [parent,label,inputs,args] = parse(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'capital');
    [parent,label,inputs,args] = parse_(parent,label,varargin{:});
    inputs = parent.getHandlesOfLabels(inputs);
end

function [parent,label,inputs,args] = parse_(parent,label,inputs,color,args)
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

