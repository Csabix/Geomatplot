function h = SegmentSequence(varargin)
% SegmentSequence draws lines by connecting members of point lists
%   SegmentSequence(A,B,C,D,...) draws line segments between point paris, e.g.: it connects A and B,
%       then D and C, ect. This connecting behaviour can be changed with breakEvery optional
%       argument. The A,B,C,D,... inputs can be point sequences or polygons too.
%
%   SegmentSequence(A,B,...,callback) draws line segments between the retuned (x,y) coordinates of a
%       given callback function of the form
%           callback(A,B,...) -> [x,y]
%       where A,B,... are n>=1 number of any Geomaplot handles, and their values will be passed to
%       the given callback. For example, if A is a point, then its position vector [x y] will be
%       given to the callback to calculate with. The output is expected to be a pair two vector of
%       x and y coordinates.
%       Note that if the callback throws any error, the excecution does not stop, the point sequence
%       goes into the 'undefined' state and it will not be drawn.
%
%   SegmentSequence(__,breakEvery) by default, SegmentSequence connects point pairs, but given an
%       nonnegative integer here can change where would it break the lines. Alternatively, one can
%       write 'strip' (=0), 'points' (=1), 'lines' (=2, default), or 'triangles' (=3) here instead
%       of integers for better code readability.
%
%   SegmentSequence(___,linespec)  specifies line style, the default is 'k-'.
%
%   SegmentSequence(___,linespec,linewidth)  also specifies the line thichness.
%
%   SegmentSequence(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = SegmentSequence(___)  returns the created handle.
%
%   See also GEOMATPLOT, SEGMENT, PointSequence, POLYGON

    [parent, varargin] = Geomatplot.extractGeomatplot(varargin);   
    [label , varargin] = parent.extractLabel(varargin,'segseq');
    [inputs, varargin] = parent.extractInputs(varargin);

    usercallback = [];
    if ~isempty(varargin) && isa(varargin{1},'function_handle')
        [usercallback,varargin] = parse_callback(inputs,varargin{:});
        n = abs(nargout(usercallback));
    end
    if ~isempty(varargin) % extract connection frequency from input
        breakEvery = varargin{1};
        if isscalar(breakEvery) && isnumeric(breakEvery) && floor(breakEvery)==breakEvery && breakEvery >= 0
            varargin = varargin(2:end);
        elseif ischar(breakEvery) || isstring(breakEvery)
            switch breakEvery
                case 'strip';     breakEvery = 0;
                case 'points';    breakEvery = 1;
                case 'lines';     breakEvery = 2;
                case 'triangles'; breakEvery = 3;
                otherwise;        breakEvery = -2; % so we now this was not processed
            end
            if breakEvery == -2
                breakEvery = 2;
            else
                varargin = varargin(2:end);
            end
        else
            breakEvery = 2;
        end
    else
        breakEvery = 2;
    end

    args = dlines.parse_inputs_(varargin{:});
    
    function [x,y] = internalcallback1(varargin)
        params = cell(1,nargin);
        for i=1:length(varargin)
            params{i} = varargin{i}.value;
        end
        xy = usercallback(params{:});
        x = xy(:,1); y = xy(:,2);
        if breakEvery ~= 0
            len = length(x)/breakEvery;
            x = reshape(vertcat(reshape(x,breakEvery,[]),NaN(1,len)),1,[]);
            y = reshape(vertcat(reshape(y,breakEvery,[]),NaN(1,len)),1,[]);
        end
    end

    function [x,y] = internalcallback2(varargin)
        params = cell(1,nargin);
        for i=1:length(varargin)
            params{i} = varargin{i}.value;
        end
        [x,y] = usercallback(params{:});
        if breakEvery ~= 0
            len = numel(x)/breakEvery;
            x = reshape(vertcat(reshape(x',breakEvery,[]),NaN(1,len)),1,[]);
            y = reshape(vertcat(reshape(y',breakEvery,[]),NaN(1,len)),1,[]);
        end
    end

    function [x,y] = segmentseq_concat(varargin)
        xy = []; % todo preallocate?
        for i = 1:length(varargin)
            xy = vertcat(xy,varargin{i}.value);
        end
        x = xy(:,1); y = xy(:,2);
        if breakEvery ~= 0
            len = length(x)/breakEvery;
            x = reshape(vertcat(reshape(x,breakEvery,[]),NaN(1,len)),1,[]);
            y = reshape(vertcat(reshape(y,breakEvery,[]),NaN(1,len)),1,[]);
        end
    end
    
    if isempty(usercallback)
        callback = @segmentseq_concat;
    else
        switch n
            case 1;    callback = @internalcallback1;
            case 2;    callback = @internalcallback2;
            otherwise; error 'wrong number of callback outputs'
        end
    end

    h_ = dlines(parent,label,inputs,callback,args);

    if nargout == 1; h = h_; end
end

function [usercallback,varargin] = parse_callback(inputs,usercallback,varargin)
    arguments
        inputs          (1,:) cell                                         %#ok<INUSA> 
        usercallback    (1,1) function_handle {mustBeSegmentsCallback(usercallback,inputs)}
    end
    arguments (Repeating)
        varargin
    end
end

function mustBeSegmentsCallback(usercallback,inputs)
    nin = nargin(usercallback);
    need = length(inputs);
    if nin<0 && abs(nin)>need+1 || nin>=0 && nin~=need
        eidType = 'SegmentSequence:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)) ' number of arguments.'];
        throw(MException(eidType,msgType));
    end
end