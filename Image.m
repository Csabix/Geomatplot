function h = Image(usercallback,varargin)
    [parent,label,inputs,corner0,corner1] = parse_image_inputs(varargin{:});
    if nargin(usercallback) ~= length(inputs)+2
        eidType = 'Image:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)+2) ' number of arguments with the\n' ...
                   'first two being the X and Y sample positions.'];
        throw(MException(eidType,msgType));
    end

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

function [parent,label,inputs,corner0,corner1] = parse_image_inputs(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'capital');
    [parent,label,inputs,corner0,corner1]= parse_image_inputs_(parent,label,varargin{:});
    inputs = parent.getHandlesOfLabels(inputs);
end

function [parent,label,inputs,corner0,corner1] = parse_image_inputs_(parent,label,inputs,corner0,corner1)
    arguments
        parent          (1,1) Geomatplot
        label           (1,:) char      {mustBeValidVariableName}
        inputs          (1,:) cell      {drawing.mustBeInputList(inputs,parent)}
        corner0                         {mustBePoint} = [0 0]
        corner1                         {mustBePoint} = [1 1]
    end
end

function mustBePoint(x)
    if ~(isnumeric(x) && length(x)==2 || isa(x,'point_base'))
        eidType = 'mustBePoint:notPoint';
        msgType = 'The input must be a position or a point drawing';
        throwAsCaller(MException(eidType,msgType));
    end
end
