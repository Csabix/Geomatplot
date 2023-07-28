function h = Curve(varargin)
% Curve  draws a curve with the given callback function
%   Curve({A,B,...},callback) draws a curve using the given parametric function handle of the form
%           callback(t,A,B,...) -> [x y]
%       where A,B,... are n >= 1 number of ony Geomaplot handles, and their values will be passed to
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
%   See also Circle, CirclularArc, POINT, DISTANCE, INTERSECT, IMAGE

    [parent,label,inputs,usercallback,linespec,args] = parse(varargin{:});
    
    n = abs(nargout(usercallback));
    function varargout = internalcallback(varargin)
        params = cell(1,nargin-1);
        for i=2:length(varargin)
            params{i-1} = varargin{i}.value;
        end
        [varargout{1:n}] = usercallback(varargin{1},params{:});
    end

    h_ = dcurve(parent,label,inputs,linespec,@internalcallback,args);

    if nargout == 1; h = h_; end
end

function [parent,label,inputs,usercallback,linespec,args] = parse(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);   
    [label,varargin] = parent.extractLabel(varargin,'small');
    [parent,label,inputs,usercallback,linespec,args] = parse_(parent,label,varargin{:});
    inputs = parent.getHandlesOfLabels(inputs);
end

function [parent,label,inputs,usercallback,linespec,args] = parse_(parent,label,inputs,usercallback,linespec,args)
    arguments
        parent         (1,1) Geomatplot
        label          (1,:) char            {mustBeValidVariableName}
        inputs         (1,:) cell            {drawing.mustBeInputList(inputs,parent)}
        usercallback   (1,1) function_handle {mustBeCurveCallback(usercallback,inputs)}
        linespec       (1,:) char            {drawing.mustBeLineSpec}        = 'k-'
        args.LineWidth (1,1) double          {mustBePositive}                = 1.5
        args.LineStyle (1,:) char
        args.Marker    (1,:) char
        args.Color                           {drawing.mustBeColor}           = 'k'
    end
end

function mustBeCurveCallback(usercallback,inputs)
    if nargin(usercallback) ~= length(inputs)+1
        eidType = 'Curve:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)+1) ' number of arguments with the\n' ...
                   'first one being a column vector of sample points (t).'];
        throw(MException(eidType,msgType));
    end
end