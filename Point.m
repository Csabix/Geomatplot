function h = Point(varargin)
% Point  places a moveable point on canvas
%   Point() awaits user to click on the current figure to draw the point onto. Afterwards, the
%       execution resumes and the point remains a moveable. It will also update Geomatplot drawings
%       that depend on it when moved.
%
%   Point([x y]) specifies starting position of the point, thus no user input is needed after the
%       call.
%
%   Point(label,___)  provides a label for the point.
%
%   Point(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. Thus must preceed the label argument if that is given also.
%
%   Point(___,color)  specifies the color of the point and its label, the default is 'b'. This may
%       be a colorname or a three element vector.
%
%   Point(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = Point(___)  returns the created handle.

    [parent,label,args] = parse(varargin{:});
    h_ = mpoint(parent,label,args);
    
    if nargout == 1; h = h_; end
end

function [parent,label,args] = parse(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'capital');
    [position,varargin] = drawing.extractPosition(varargin);
    [parent,label,args] = parse_(parent,label,position,varargin{:});
end

function [parent,label,args] = parse_(parent,label,position,color,args)
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
