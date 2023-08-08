function h = Text(varargin)

%% usage
% pos = Point([0,1]);  or   pos = [0 1];
%
% OK:
% Text(pos,'asd')
% Text(pos, {B}, @(B) num2str(B))    
% Text(pos,  B,  @(B) num2str(B))
%
% TODO ?
% Text(pos, A)    ---- toText in every drawing? (short/long desc.)
% Text({A},@str)  ---- short for Text(A, A, @str)
%
% TODO: pass extra arguments to `dtext`

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'Text_');
    % 1 a) const position
    [position,varargin] = drawing.extractPosition(varargin);
    isConstPos = true;
    % 1 b) non-const position -> mpoint/dpoint
    if isempty(position) && ~isempty(varargin)
        if isa(varargin{1},'point_base')
            isConstPos = false;
            position = varargin{1};
            varargin = varargin(2:end);
        else
            throw(MException('Text:notPosition','Couldn''t parse position argument'));
        end
    end
    % 2 a) const text
    if ~isempty(varargin) && (size(varargin{1},1)==1 && ischar(varargin{1}) || isStringScalar(varargin{1}) )
        isConstText = true;
        txt = varargin{1};
        varargin = varargin(2:end);
        if ~isempty(varargin)
            args = parse_text_const(varargin);
        else
            args = struct;
        end
    else
    % 2 b) non-const text -> callback
        isConstText = false;
        [inputs,  varargin] = parent.extractInputs(varargin,0,inf);
        [usercallback,args] = parse_text_callback(inputs,varargin{:});
    end
    
    function [p,t] = internalTextCallback1()
        p = position;
        t = txt;
    end
    function [p,t] = internalTextCallback2(varargin)
        p = position;
        params = cell(1,nargin);
        for i=1:length(varargin)
            params{i} = varargin{i}.value;
        end
        t = usercallback(params{:});
    end
    function [p,t] = internalTextCallback3(pos)
        p = pos.value;
        t = txt;
    end
    function [p,t] = internalTextCallback4(pos,varargin)
        p = pos.value;
        params = cell(1,nargin-1);
        for i=1:length(varargin)
            params{i} = varargin{i}.value;
        end
        t = usercallback(params{:});
    end
    
    if isConstPos 
        if isConstText
            inputs = {};
            callback = @internalTextCallback1;
        else
            callback = @internalTextCallback2;
        end
    else
        if isConstText
            inputs = {position};
            callback = @internalTextCallback3;
        else
            inputs = [{position},inputs(:)'];
            callback = @internalTextCallback4;
        end
    end
    
    inputs = parent.getHandlesOfLabels(inputs);
    
    h_ = dtext(parent,label,inputs,callback,args);
    
    if nargout == 1; h = h_; end

end


function params = parse_text_const(params)
    arguments
        params.FontSize   (1,1) double          {mustBePositive}            = 11
    end
end

function [usercallback, params] = parse_text_callback(inputs,usercallback,params)
    arguments
        inputs            (1,:) cell                                        %#ok<INUSA> 
        usercallback      (1,1) function_handle {mustBeTextCallback(usercallback,inputs)}
        params.FontSize   (1,1) double          {mustBePositive}            = 11
    end
end

function mustBeTextCallback(usercallback,inputs)
    if nargin(usercallback) ~= length(inputs)
        eidType = 'Text:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)) ' number of arguments.'];
        throw(MException(eidType,msgType));
    end
end