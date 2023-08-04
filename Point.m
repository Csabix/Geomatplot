function h = Point(varargin)
% Point  places a moveable point on the canvas
%   Point() awaits user to click on the current figure to draw the point onto. Afterwards, the
%       execution resumes and the point remains a moveable. It will also update any Geomatplot
%       drawings that depend on it when moved.
%
%   Point([x y]) specifies starting position of the point, thus no user input is needed after the
%       call.
%
%   Point({A,B..},callback) creates a dependent point with a given callback of the form
%           callback(A,B,...) -> [x y]
%       where A,B,... are n>=1 number of any Geomaplot handles, and their values will be passed to
%       the given callback. For example, if A is a point, then its position vector [x y] will be
%       given to the callback to calculate with. The output is expected to be a single pair of
%       coordinates.
%       Note that if the callback throws any error, the excecution does not stop, the point goes
%       into the 'undefined' state and it will not be drawn.
%
%   Point(label,___)  provides a label for the point.
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
%   See also GEOMATPLOT, SEGMENT, CIRCLE, MIDPOINT, POLYGON

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'capital');
    [position,varargin] = drawing.extractPosition(varargin);
    if isempty(position) && ~isempty(varargin) && iscell(varargin{1})
        isdependent = true;  % because cannot define function inside an if statement
        [parent,label,inputs,usercallback,args] = parse_dpoint(parent,label,varargin{:});
        n = abs(nargout(usercallback));
    else
        isdependent = false;
        [parent,label,args] = parse_mpoint(parent,label,position,varargin{:});
    end
    
    function varargout = internalcallback(varargin)
        params = cell(1,nargin);
        for i=1:length(varargin)
            params{i} = varargin{i}.value;
        end
        [varargout{1:n}] = usercallback(params{:});
    end

    if isdependent
        h_ = dpoint(parent,label,inputs,@internalcallback,args);
    else
        h_ = mpoint(parent,label,args);
    end
    
    if nargout == 1; h = h_; end
end

function [parent,label,args] = parse_mpoint(parent,label,position,color,args)
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

function [parent,label,inputs,usercallback,args] = parse_dpoint(parent,label,inputs,usercallback,color,args)
    arguments
        parent          (1,1) Geomatplot
        label           (1,:) char            {mustBeValidVariableName}
        inputs          (1,:) cell            {drawing.mustBeInputList(inputs,parent)}
        usercallback    (1,1) function_handle {mustBePointCallback(usercallback,inputs)}
        color                                 {drawing.mustBeColor}                      = 'k'
        args.MarkerSize (1,1) double          {mustBePositive}                           = 7
        args.LabelAlpha (1,1) double          {mustBeInRange(args.LabelAlpha,0,1)}       = 0
        args.LabelTextColor                   {drawing.mustBeColor}
        args.LineWidth  (1,1) double          {mustBePositive}
    end
    args.Label = label;
    args.Color = color;
    if ~isfield(args,'LabelTextColor'); args.LabelTextColor = color; end
end

function mustBePointCallback(usercallback,inputs)
    if nargin(usercallback) ~= length(inputs)
        eidType = 'Point:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)) ' number of arguments.'];
        throw(MException(eidType,msgType));
    end
end
