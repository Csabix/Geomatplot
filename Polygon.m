function h = Polygon(varargin)
% Polygon  places a movable polygon on the canvas
%   Polygon() awaits user to click on the current figure to draw the polygon vertex by vertex.
%       Afterwards, the execution resumes and the polygon is adjustable. It will also update
%       any Geomatplot drawings that depend on it when moved. Verices may be moved, or even created
%       and deleted using the context menu when right clicking.
%
%   Point([x y]) specifies starting positions of the polygon vertices, thus no user input is needed
%       after the call. It expects a Nx2 matrix as input.
%
%   Point(label,___)  provides a label for the polygon.
%
%   Point(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. This must preceed the label argument if that is given also.
%
%   Point(___,color)  specifies the color of the point and its label, the default is 'b'. This may
%       be a colorname or a three element vector.
%
%   Point(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = Point(___)  returns the created handle.
%
%   See also GEOMATPLOT, POINT, SEGMENT, CIRCLE, INTERSECT

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'poly');
    [position,varargin] = drawing.extractPosition(varargin,inf);
    args = parse_(position,varargin{:});
    h_ = mpolygon(parent,label,args);
    
    if nargout == 1; h=h_; end
end

function args = parse_(position,color,args)
    arguments
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
    args.Color = color;
    if ~isfield(args,'LabelTextColor'); args.LabelTextColor = color; end
    if ~isempty(position); args.Position = position; end
end