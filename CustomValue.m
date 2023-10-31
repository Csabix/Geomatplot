function h = CustomValue(varargin)
% CustomValue creates a dependent custom value obejct
%   CustomValue({A,B..},callback) creates a dependent custom object with a
%   given callback of the form
%           callback(A,B,...) -> s
%       where A,B,... are n>=1 number of any Geomaplot handles, and their
%       values will be passed to the given callback. For example, if A is a
%       point, then its position vector [x y] will be  given to the
%       callback to calculate with. The output is expected to  be a single
%       value. Note that if the callback throws any error, the excecution
%       does not stop, the object goes into the 'undefined' state and
%       anything depending on it will be also 'undefined'.
%
%   CustomValue(label,___)  provides a label for the scalar.
%
%   CustomValue(parent,___)  draws onto the given geomatplot, axes, or
%   figure instead of the current one. This must preceed the label argument
%   if that is also given.
%
%   h = CustomValue(___)  returns the created handle.

    [parent,  varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,   varargin] = parent.extractLabel(varargin,'custom');
    [inputs,  varargin] = parent.extractInputs(varargin,0,inf,true);
    
    if length(varargin) == 1 && isa(varargin{1},'function_handle')
        [usercallback,~] = parse_callback(inputs,varargin{:});
        n = abs(nargout(usercallback));
        callback = [];
    else
        throw(MException('Scalar:invalidInputPattern','Unknown overload.'))
    end
    
    function varargout = internalcallback(varargin)
        params = cell(1,nargin);
        for i=1:length(varargin)
            params{i} = varargin{i}.value;
        end
        [varargout{1:n}] = usercallback(params{:});
    end
    
    if isempty(callback)
        callback = @internalcallback;
    end
    h_ = dcustomvalue(parent,label,inputs,callback);
    
    if nargout == 1; h = h_; end
end

function [usercallback,varargin] = parse_callback(inputs,usercallback,varargin)
    arguments
        inputs          (1,:) cell                                         %#ok<INUSA> 
        usercallback    (1,1) function_handle {mustBeCustomValueCallback(usercallback,inputs)}
    end
    arguments (Repeating)
        varargin
    end
end
function mustBeCustomValueCallback(usercallback,inputs)
    nin = nargin(usercallback);
    need = length(inputs);
    if (nin<0 && abs(nin)>need+1)|| nin >= 0 && nin ~= need
        eidType = 'CustomValue:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)) ' number of arguments.'];
        throw(MException(eidType,msgType));
    end
end
