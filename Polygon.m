function h = Polygon(varargin)
% Polygon  places a movable or a dependent polygon on the canvas
%   Polygon() awaits user to click on the current figure to draw the polygon vertex by vertex.
%       Afterwards, the execution resumes and the polygon is adjustable. It will also update
%       any Geomatplot drawings that depend on it when moved. Verices may be moved, or even created
%       and deleted using the context menu when right clicking.
%
%   Polygon([x y]) specifies starting positions of the polygon vertices, thus no user input is
%       needed after the call. It expects a Nx2 matrix as input.
%
%   Polygon(A,B,...) creates a dependent polygon with A,B,... vertices where the inputs can be
%       points, a point sequence, or another polygon. Then, the input points are simply concatenated
%       and connected.
%
%   Polygon(label,___)  provides a label for the polygon.
%
%   Polygon(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. This must preceed the label argument if that is given also.
%
%   Polygon(___,color)  specifies the color of the point and its label, the default is 'b'. This may
%       be a colorname or a three element vector.
%
%   Polygon(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = Polygon(___)  returns the created handle.
%
%   See also GEOMATPLOT, POINT, SEGMENT, CIRCLE, INTERSECT

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'poly');
    [position,varargin] = drawing.extractPosition(varargin,inf);
    
    if isempty(position) && ~isempty(varargin)
        [inputs,varargin] = parent.extractInputs(varargin,0,inf);
        args = parse_dpolygon(varargin{:}); % todo check inputs
        h_ = dpolygon(parent,label,inputs,@dpoly_callback,args);
    else
        args = parse_mpolygon(position,varargin{:});
        h_ = mpolygon(parent,label,args);
    end

    if nargout == 1; h = h_; end
end

function xy = dpoly_callback(varargin)
    xy = []; % todo preallocate?
    for i = 1:length(varargin)
        xy = vertcat(xy,varargin{i}.value);
    end
end

function args = parse_mpolygon(position,color,args) % todo linespec!
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

function params = parse_dpolygon(linespec,linewidth,params) % todo more functionality!
    arguments
        linespec          (1,:) char   {drawing.mustBeLineSpec}              = 'k'
        linewidth         (1,1) double {mustBePositive}                      =  1
        params.MarkerSize (1,1) double {mustBePositive}                      = 7
        params.LineWidth  (1,1) double {mustBePositive}
        params.FaceAlpha  (1,1) double {mustBeInRange(params.FaceAlpha,0,1)} = 0.15
        params.LineStyle  (1,:) char
        params.Marker     (1,:) char
        params.Color                   %{drawing.mustBeColor}
    end
    if ~isfield(params,'LineWidth'); params.LineWidth = linewidth; end
    params = dlines.applyLineSpec(params,linespec);
end