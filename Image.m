function h = Image(varargin)
% Image  visualizes a given 2D function over an area
%   Image({A,B,...},callback) draws an image using the given callback function handle of the form
%           callback(X,Y,A,B,...) -> C
%       where A,B,... are n >= 1 number of any Geomaplot handles, and their values will be passed to
%       the given callback. For example, if A is a point, then its position vector [x y] will be
%       given to the callback to calculate with. The parameter X and Y are given automatically and
%       are NxM matrices retuned from a meshgrid command. The X(i,j) and Y(i,j) position corresponds
%       to the position it appears on the canvas. The output is expected to be an NxM array of
%       function evaluations or NxMx3 array for colors.
%       Note that if the callback throws any error, the excecution does not stop, the image goes
%       into the 'undefined' state and it will not be drawn.
%       For example, the following visualizes the distance function of a single point:
%           Image({Point},@(X,Y,A) sqrt((X-A(1)).^2 + (Y-A(2)).^2))
%
%   Image({A,B,...},callback,corner0,corner1)  specifies a corners (eg. lower left and upper right)
%       of the plotted region. The values may be two element position vectors, or even point objects
%       allowing for dynamically changing the visualized function domain. The default corners are
%       [0,0] and [1,1]. 
%
%   Image(label,{___})  provides a label for the curve. The label is not drawn.
%
%   Image(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. Thus must preceed the label argument if that is given also.
%
%   Image(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = Image(___)  returns the created handle.
%
%   See also Curve, POINT, DISTANCE, Circle

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);  
    [label,varargin] = parent.extractLabel(varargin,'image');
    [inputs,varargin] = parent.extractInputs(varargin);
    [usercallback,corner0,corner1]= parse_(inputs,varargin{:});
    inputs = parent.getHandlesOfLabels(inputs);

    n = abs(nargout(usercallback));
    function varargout = internalcallback(varargin)
        params = cell(1,nargin-2);
        for i=3:length(varargin)
            params{i-2} = varargin{i}.value;
        end
        [varargout{1:n}] = usercallback(varargin{1:2},params{:});
    end
    h_ = dimage(parent,label,inputs,@internalcallback,corner0,corner1,{});

    if nargout == 1; h=h_; end
end

function [usercallback,corner0,corner1] = parse_(inputs,usercallback,corner0,corner1)
    arguments
        inputs          (1,:) cell                                            %#ok<INUSA> 
        usercallback    (1,1) function_handle   {mustBeImageCallback(usercallback,inputs)}
        corner0                                 {mustBePoint} = [0 0]
        corner1                                 {mustBePoint} = [1 1]
    end
end

function mustBeImageCallback(usercallback,inputs)
    if nargin(usercallback) ~= length(inputs)+2
        msgType = ['Callback needs ' int2str(length(inputs)+2) ' number of arguments with the\n first two being the X and Y sample positions.'];
        throw(MException('Image:callbackWrongNumberOfArguments',msgType));
    end
end

function mustBePoint(x)
    if ~(isnumeric(x) && length(x)==2 || isa(x,'point_base'))
        throwAsCaller(MException('mustBePoint:notPoint','The input must be a position or a point drawing'));
    end
end
