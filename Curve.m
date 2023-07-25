function h = Curve(callback,varargin)
    arguments
        callback (1,1) function_handle
    end
    arguments (Repeating)
        varargin
    end
    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin{:});
    if nargin(callback) ~= length(inputs)+1
        eidType = 'Curve:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)+1) ' number of arguments with the\n' ...
                   'first one being a column vector of sample points (t).'];
        throw(MException(eidType,msgType));
    end
    h_ = dcurve(parent,label,inputs,linespec,callback,args);

    if nargout == 1; h=h_; end
end