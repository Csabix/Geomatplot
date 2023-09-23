function h = Curve(varargin)
% Curve  draws a curve with the given callback function
%   Curve({A,B,...},callback) draws a curve using the given parametric function handle of the form
%           callback(t,A,B,...) -> [x y]
%       where A,B,... are n >= 1 number of any Geomaplot handles, and their values will be passed to
%       the given callback. For example, if A is a point, then its position vector [x y] will be
%       given to the callback to calculate with. The parameter t is an automatically given column
%       vector with N elements and values between 0 and 1. The output is expected to be an Nx2
%       matrix, or two Nx1 vectors corresponding the the curve points at each t parameter value.
%       Note that if the callback throws any error, the excecution does not stop, the curve goes
%       into the 'undefined' state and it will not be drawn.
%       For example, the follwoing draws a quadratic Bézier curve after putting down three points:
%           Curve({Point,Point,Point},@(t,b0,b1,b2) b0.*(1-t).^2 + 2*b1.*t.*(1-t) + b2.*t.^2)
%
%   Curve(label,{___})  provides a label for the curve. The label is not drawn.
%
%   Curve(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. Thus must preceed the label argument if that is given also.
%
%   Curve(___,linespec)  specifies line style, the default is 'k-'.
%
%   Curve(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = Curve(___)  returns the created handle.
%
%   Name-Value Arguments
%
%       Resolution - 512 (default) | positive integer
%           The Curve will consist of Resolution-1 number of line segments when drawn. When someting
%           is being moved the resolution is decreased to increase responsiveness.
%
%   See also Circle, CircularArc, POINT, DISTANCE, INTERSECT, IMAGE

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);   
    [label, varargin] = parent.extractLabel(varargin,'curve');   
    [inputs,varargin] = parent.extractInputs(varargin);
    [usercallback,params,resolution] = parse_(inputs,varargin{:});
    
    n = abs(nargout(usercallback));
    function varargout = internalcallback(varargin)
        args = cell(1,nargin-1);
        for i=2:length(varargin)
            args{i-1} = varargin{i}.value;
        end
        [varargout{1:n}] = usercallback(varargin{1},args{:});
    end

    h_ = dcurve(parent,label,inputs,@internalcallback,params,resolution);

    if nargout == 1; h = h_; end
end

function [usercallback,params,resolution] = parse_(inputs,usercallback,linespec,lnwidth,params,options)
    arguments
        inputs       (1,:) cell                                          %#ok<INUSA> 
        usercallback (1,1) function_handle {mustBeCurveCallback(usercallback,inputs)}
        linespec     (1,:) char            {drawing.mustBeLineSpec}        = 'k'
        lnwidth      (1,1) double          {mustBePositive}                =  1
        params.LineWidth   (1,1) double    {mustBePositive}
        params.LineStyle   (1,:) char
        params.Marker      (1,:) char
        params.Color                       {drawing.mustBeColor}
        options.Resolution (1,1) double    {mustBeInteger,mustBePositive} = 512
        options.c          (1,1) double    {mustBePositive} % hack, do not intentionally use this name value arg
        options.r          (1,1) double    {mustBePositive} % hack, do not intentionally use this name value arg   
    end
    if isfield(options,'c'); linespec = 'c'; lnwidth = options.c; end
    if isfield(options,'r'); linespec = 'r'; lnwidth = options.r; end
    if isfield(options,'Resolution'); resolution = options.Resolution; end
    if ~isfield(options,'LineWidth'); params.LineWidth = lnwidth; end
    params = dlines.applyLineSpec(params,linespec);
end

function mustBeCurveCallback(usercallback,inputs)    
    nin = nargin(usercallback);
    need = length(inputs)+1;
    if nin<0 && abs(nin)>need+1 || nin>=0 && nin~=need
        msgType = ['Callback needs ' int2str(length(inputs)+1) ' number of arguments with the\n first one being a column vector of sample points (t).'];
        throw(MException('Curve:callbackWrongNumberOfArguments',msgType));
    end
end