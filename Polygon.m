function h = Polygon(varargin)
% todo write help

    [parent,label,args] = parse(varargin{:});
    h_ = mpolygon(parent,label,args);
    
    if nargout == 1; h=h_; end
end

function [parent,label,args] = parse(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'small');
    [position,varargin] = drawing.extractPosition(varargin,inf);
    [parent,label,args] = parse_(parent,label,position,varargin{:});
end

function [parent,label,args] = parse_(parent,label,position,color,args)
    arguments
        parent          (1,1) Geomatplot
        label           (1,:) char      {mustBeValidVariableName}
        position        (:,2) double    {mustBeReal}
        color                           {drawing.mustBeColor}               = 'b'
        args.MarkerSize (1,1) double    {mustBePositive}                    = 7
        args.LabelAlpha (1,1) double    {mustBeInRange(args.LabelAlpha,0,1)}= 0
        args.LabelTextColor             {drawing.mustBeColor}
        args.LineWidth  (1,1) double    {mustBePositive}
        args.FaceAlpha  (1,1) double    {mustBeInRange(args.FaceAlpha,0,1)} = 0.15
        args.FaceSelectable (1,1) logical                                   = true
        args.InteractionsAllowed (1,:) char {mustBeMember(args.InteractionsAllowed,{'all','none','translate','reshape'})} = 'all'
    end
    %args.Label = label;
    args.Color = color;
    if ~isfield(args,'LabelTextColor'); args.LabelTextColor = color; end
    if ~isempty(position); args.Position = position; end
end