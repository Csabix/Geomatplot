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

    [parent,  varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,   varargin] = parent.extractLabel(varargin,'capital');
    [position,varargin] = drawing.extractPosition(varargin);

    if isempty(position) && ~isempty(varargin) && (iscell(varargin{1})||isa(varargin{1},'drawing'))
        isdependent = true;  % because cannot define function inside an if statement
        [inputs,  varargin] = parent.extractInputs(varargin,0,inf);
        [usercallback,args] = parse_dpoint(inputs,varargin{:});
        n = abs(nargout(usercallback));
    else
        isdependent = false;
        args = parse_mpoint(position,varargin{:});
    end
    args.Label = label;
    
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

function params = parse_mpoint(position,color,markersize,params)
    arguments
        position            (1,2) double {mustBeReal}
        color                            {drawing.mustBeColor}               = 'b'
        markersize          (1,1) double {mustBePositive}                    = 8
        params.MarkerSize   (1,1) double {mustBePositive}
        params.LabelAlpha   (1,1) double {mustBeInRange(params.LabelAlpha,0,1)}= 0
        params.LabelTextColor            {drawing.mustBeColor}
        params.LineWidth    (1,1) double {mustBePositive}
        params.LabelVisible (1,:) char   {mustBeMember(params.LabelVisible,{'on','off','hover'})}
        params.Visible      (1,:) char   {mustBeMember(params.Visible,{'on','off'})}
    end
    params.Color = color;
    if ~isfield(params,'LabelTextColor'); params.LabelTextColor = color; end
    if ~isfield(params,'MarkerSize');     params.MarkerSize = markersize; end
    if ~isempty(position); params.Position = position; end
end

function [usercallback,params] = parse_dpoint(inputs,usercallback,color,markersize,params)
    arguments
        inputs          (1,:) cell                                         %#ok<INUSA> 
        usercallback    (1,1) function_handle {mustBePointCallback(usercallback,inputs)}
        color                                 {drawing.mustBeColor}                      = 'k'
        markersize          (1,1) double      {mustBePositive}                           = 6
        params.MarkerSize   (1,1) double      {mustBePositive}
        params.LabelAlpha   (1,1) double      {mustBeInRange(params.LabelAlpha,0,1)}     = 0
        params.LabelVisible (1,:) char        {mustBeMember(params.LabelVisible,{'on','off','hover'})}
        params.Visible      (1,:) char        {mustBeMember(params.Visible,{'on','off'})}
    end
    params.Color = color;
    if ~isfield(params,'LabelTextColor'); params.LabelTextColor = color; end
    if ~isfield(params,'MarkerSize');     params.MarkerSize = markersize; end
end

function mustBePointCallback(usercallback,inputs)
    if nargin(usercallback) ~= length(inputs)
        eidType = 'Point:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)) ' number of arguments.'];
        throw(MException(eidType,msgType));
    end
end
