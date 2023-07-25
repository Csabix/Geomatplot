function h = Curve(usercallback,varargin)
    arguments
        usercallback (1,1) function_handle
    end
    arguments (Repeating)
        varargin
    end

    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin{:});
    if nargin(usercallback) ~= length(inputs)+1
        eidType = 'Curve:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)+1) ' number of arguments with the\n' ...
                   'first one being a column vector of sample points (t).'];
        throw(MException(eidType,msgType));
    end
    
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