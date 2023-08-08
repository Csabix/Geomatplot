function h = Text(varargin)

%% usage
% pos = Point([0,1]);  or   pos = [0 1]; or pos = {'A'};
%
% Text(pos,'asd')
% Text(pos, {B}, @(B) num2str(B))    
% Text(pos,  B,  @(B) num2str(B))
% Text(pos, A)   --- needs some work (short text for all drawing?)

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'Text_');
    
    [position,varargin] = parent.extractPoint(varargin);
    isConstPos = isnumeric(position);
    
    inputs = {};
    % 2 a) const text
    [txt,varargin] = drawing.extractText(varargin);
    if ~isempty(txt) 
        textType = 'const';
        [args,offset] = parse_text_const(position,varargin{:});
    else
    % 2 b) non-const text -> callback or print object
        [inputs,  varargin] = parent.extractInputs(varargin,0,inf);
        if isempty(varargin) || ~isa(varargin{1},'function_handle')
            textType = 'drawing';
            [args,offset] = parse_text_const(position,varargin{:});
        else
            textType = 'callback';
            [usercallback,args,offset] = parse_text_callback(position,inputs,varargin{:});
        end
    end
    
    function [p,t] = text_constPos_constStr()
        p = position;
        t = txt;
    end
    function [p,t] = text_constPos_varStr(varargin)
        p = position;
        params = cell(1,nargin);
        for i=1:length(varargin)
            params{i} = varargin{i}.value;
        end
        t = usercallback(params{:});
    end
    function [p,t] = text_constPos_printDrawing(varargin)
        p = position;
        t = strings(length(varargin),1);
        for i=1:length(varargin)
            t(i) = num2str(round(mean(varargin{i}.value, 1), 4));
        end
    end
    function [p,t] = text_varPos_constStr(pos)
        p = pos.value;
        t = txt;
    end
    function [p,t] = text_varPos_varStr(pos,varargin)
        p = pos.value;
        params = cell(1,nargin-1);
        for i=1:length(varargin)
            params{i} = varargin{i}.value;
        end
        t = usercallback(params{:});
    end
    function [p,t] = text_varPos_printDrawing(pos,varargin)
        p = pos.value;
        t = strings(length(varargin),1);
        for i=1:length(varargin)
            t(i) = num2str(round(mean(varargin{i}.value, 1), 4));
        end
    end
    
    if ~isConstPos
        inputs = [{position},inputs(:)'];
    end

    switch textType
    case 'const'
        if isConstPos
            callback = @text_constPos_constStr;
        else
            callback = @text_varPos_constStr;
        end
    case 'drawing'
        if isConstPos
            callback = @text_constPos_printDrawing;
        else
            callback = @text_varPos_printDrawing;
        end
    case 'callback'
        if isConstPos
            callback = @text_constPos_varStr;
        else
            callback = @text_varPos_varStr;
        end
    end
    
    h_ = dtext(parent,label,inputs,callback,args,offset);
    
    if nargout == 1; h = h_; end

end


function [params,offset] = parse_text_const(pos,params,options)
    arguments
        pos                                                                 %#ok<INUSA> 
        params.FontSize             (1,1) double   {mustBePositive}                  = 11
        params.FontWeight           (1,:) char     {mustBeMember(params.FontWeight,{'normal','bold'})}
        params.FontAngle            (1,:) char     {mustBeMember(params.FontAngle,{'normal','italic'})}
        params.FontName             (1,:) char
        params.Color                (1,:) char     {drawing.mustBeColor}
        params.HorizontalAlignment  (1,:) char     {mustBeMember(params.HorizontalAlignment,{'left','center','right'})}
        params.Units                (1,:) char     {mustBeMember(params.Units,{'data','normalized','inches','centimeters','characters','points','pixels'})}
        params.Interpreter          (1,:) char     {mustBeMember(params.Interpreter,{'tex','latex','none'})}
        params.Margin               (1,1) double                                     = 7
        options.Offset              (1,1) double   {mustBeInteger,mustBeNonnegative} = ~isnumeric(pos)*3
    end
    offset = options.Offset;
end

function [usercallback, params, offset] = parse_text_callback(pos,inputs,usercallback,params,options)
    arguments
        pos                                                                 %#ok<INUSA> 
        inputs            (1,:) cell                                        %#ok<INUSA> 
        usercallback      (1,1) function_handle {mustBeTextCallback(usercallback,inputs)}
        params.FontSize             (1,1) double   {mustBePositive}                  = 11
        params.FontWeight           (1,:) char     {mustBeMember(params.FontWeight,{'normal','bold'})}
        params.FontAngle            (1,:) char     {mustBeMember(params.FontAngle,{'normal','italic'})}
        params.FontName             (1,:) char
        params.Color                (1,:) char     {drawing.mustBeColor}
        params.HorizontalAlignment  (1,:) char     {mustBeMember(params.HorizontalAlignment,{'left','center','right'})}
        params.Units                (1,:) char     {mustBeMember(params.Units,{'data','normalized','inches','centimeters','characters','points','pixels'})}
        params.Interpreter          (1,:) char     {mustBeMember(params.Interpreter,{'tex','latex','none'})}
        params.Margin               (1,1) double                                     = 7
        options.Offset              (1,1) double   {mustBeInteger,mustBeNonnegative} = ~isnumeric(pos)*3
    end
    offset = options.Offset;
end

function mustBeTextCallback(usercallback,inputs)
    if nargin(usercallback) ~= length(inputs)
        eidType = 'Text:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)) ' number of arguments.'];
        throw(MException(eidType,msgType));
    end
end