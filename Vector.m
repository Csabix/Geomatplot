function h = Vector(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);
    [label, varargin] = parent.extractLabel(varargin,'vec');
    [inputs,varargin] = parent.extractInputs(varargin,2,2);
    if length(varargin) == 1 && isa(varargin{1},'function_handle')
        [usercallback,~] = parse_callback(inputs,varargin{:});
        n = abs(nargout(usercallback));
        callback = [];
    elseif drawing.isInputPatternMatching(inputs,{'point_base','point_base'})
        callback = @(a,b) b.value-a.value;
        args = parse_(varargin{:});
%   elseif drawing.isInputPatternMatching(inputs,{'point_base','dvector'})
%       h = inputs{2};
%       h.pt = inputs{1};
    else
        throw(MException('Vector:invalidInputPattern','Cannot create vector for these input types.'));
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
        h_ = dvector(parent,label,inputs,callback);
    else
        h_ = dvector(parent,label,inputs,callback,inputs{1},args);
    end
    if nargout >= 1; h = h_; end
end

function params = parse_(linespec,linewidth,params)
    arguments
        linespec           (1,:) char   {drawing.mustBeLineSpec} = 'k'
        linewidth          (1,1) double {mustBePositive}         =  1
        params.MaxHeadSize (1,1) double {mustBePositive}
        params.LineWidth   (1,1) double {mustBePositive}
        params.LineStyle (1,:) char
        params.Marker    (1,:) char
        params.Color                    {drawing.mustBeColor}
    end
    if ~isfield(params,'LineWidth'); params.LineWidth = linewidth; end
    params = dlines.applyLineSpec(params,linespec);
end

function [usercallback,varargin] = parse_callback(inputs,usercallback,varargin)
    arguments
        inputs          (1,:) cell                                         %#ok<INUSA> 
        usercallback    (1,1) function_handle {mustBeVectorCallback(usercallback,inputs)}
    end
    arguments (Repeating)
        varargin
    end
end
function mustBeVectorCallback(usercallback,inputs)
    nin = nargin(usercallback);
    need = length(inputs);
    if (nin<0 && abs(nin)>need+1)|| nin >= 0 && nin ~= need
        eidType = 'CustomValue:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)) ' number of arguments.'];
        throw(MException(eidType,msgType));
    end
end


