function h = Point(varargin)
% todo write help

    [parent,label,args] = parse_mpoint_inputs(varargin{:});
    h_ = mpoint(parent,label,args);
    
    if nargout == 1; h=h_; end
end

function [parent,label,args] = parse_mpoint_inputs(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'capital');
    [position,varargin] = drawing.extractPosition(varargin);
    [parent,label,args] = parse_mpoint_inputs_(parent,label,position,varargin{:});
end

function [parent,label,args] = parse_mpoint_inputs_(parent,label,position,color,args)
    arguments
        parent          (1,1) Geomatplot
        label           (1,:) char      {mustBeValidVariableName}
        position        (:,2) double    {mustBeReal}
        color                           {drawing.mustBeColor}               = 'b'
        args.MarkerSize (1,1) double    {mustBePositive}                    = 8
        args.LabelAlpha (1,1) double    {mustBeInRange(args.LabelAlpha,0,1)}= 0
        args.LabelTextColor             {drawing.mustBeColor}
        args.LineWidth  (1,1) double    {mustBePositive}
    end
    args.Label = label;
    args.Color = color;
    if ~isfield(args,'LabelTextColor'); args.LabelTextColor = color; end
    if ~isempty(position); args.Position = position; end
end
