function [h] = PointSequence(varargin)
% PointSequence  places a dependent point sequence on the canvas
%   Polygon(A,B,...) creates a dependent polygon with A,B,... vertices where the inputs can be
%       points, a point sequence, or another polygon. Then, the input points are simply concatenated
%       and connected.
%
%   PointSequence(A,B..,callback) creates a dependent point sequence given a callback of the form
%           callback(A,B,...) -> [x y]
%       where A,B,... are n>=1 number of any Geomaplot handles, and their values will be passed to
%       the given callback. For example, if A is a point, then its position vector [x y] will be
%       given to the callback to calculate with. The output is expected to be a pair two vector of
%       x and y coordinates.
%       Note that if the callback throws any error, the excecution does not stop, the point sequence
%       goes into the 'undefined' state and it will not be drawn.
%
%   PointSequence(label,___)  provides a label for the point.
%
%   PointSequence(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. This must preceed the label argument if that is also given.
%
%   PointSequence(___,color)  specifies the color of the points, the default is 'k'.
%       This may be a colorname or a three element vector.
%
%   PointSequence(___,color,markersize) also specifies the marker size for the points.
%
%   PointSequence(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = PointSequence(___)  returns the created handle.
%
%   See also GEOMATPLOT, SEGMENT, SegmentSequence, POLYGON

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label, varargin] = parent.extractLabel(varargin,'seq');
    [inputs,varargin] = parent.extractInputs(varargin,0,inf,false);
    
    usercallback = [];
    if ~isempty(varargin) && isa(varargin{1},'function_handle')
        [usercallback,varargin] = parse_callback(inputs,varargin{:});
        n = abs(nargout(usercallback));
    end
    args = parse_(varargin{:});

    function varargout = internalcallback(varargin)
        params = cell(1,nargin);
        for i=1:length(varargin)
            params{i} = varargin{i}.value;
        end
        [varargout{1:n}] = usercallback(params{:});
    end

    if isempty(usercallback)
        callback = @pointseq_concat;
    else
        callback = @internalcallback;
    end

    h_ = dpointseq(parent,label,inputs,callback,args,false);

    if nargout == 1; h = h_; end
end

function xy = pointseq_concat(varargin)
    xy = []; % todo preallocate?
    for i = 1:length(varargin)
        xy = vertcat(xy,varargin{i}.value);
    end
end

function [usercallback,varargin] = parse_callback(inputs,usercallback,varargin)
    arguments
        inputs          (1,:) cell                                         %#ok<INUSA> 
        usercallback    (1,1) function_handle {mustBePointCallback(usercallback,inputs)}
    end
    arguments (Repeating)
        varargin
    end
end

function params = parse_(color,markersize,params)
    arguments
        color                                 {drawing.mustBeColor}                      = 'k'
        markersize          (1,1) double      {mustBePositive}                           = 20
        params.MarkerEdgeColor              {drawing.mustBeColor}
        params.MarkerFaceColor              {drawing.mustBeColor}
        params.LineWidth    (1,1) double    {mustBePositive}                    = 0.5
        params.MarkerSize   (1,1) double    {mustBePositive}
        params.MarkerColor                  {drawing.mustBeColor}               = 'k'
        params.MarkerSymbol (1,:) char      {mustBeMember(params.MarkerSymbol,{'o','+','*','x','_','|','^','v','>','<','square','diamond','pentagram','hexagram'})}='o'
        params.ColorVariable
    end
    %if ~isfield(params,'MarkerEdgeColor'); params.MarkerEdgeColor = color; end
    %if ~isfield(params,'MarkerFaceColor'); params.MarkerFaceColor = color; end
    if ~isfield(params,'MarkerColor');     params.MarkerColor     = color; end
    if ~isfield(params,'MarkerSize');      params.MarkerSize = markersize; end
end

function mustBePointCallback(usercallback,inputs)
    nin = nargin(usercallback);
    need = length(inputs);
    if nin<0 && abs(nin)>need+1 || nin>=0 && nin~=need
        eidType = 'PointSequence:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)) ' number of arguments.'];
        throw(MException(eidType,msgType));
    end
end