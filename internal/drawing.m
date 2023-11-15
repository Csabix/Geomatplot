classdef (Abstract) drawing < handle
properties
	parent  (1,1) Geomatplot
	label	(1,:) char           % indetifier
	fig                          % plot handle to ROI or matlab plot
    defined (1,1) logical = true
end


methods
    function o = drawing(parent,label,fig)
        if nargin ==0; return; end
        o.parent = parent;
        o.label = label;
        o.fig = fig;
        o.fig.UserData = o;
    end
    function s = string(o,r)
        v = o.value;
        if isempty(v); s = "[empty]"; return; end
        if any(isnan(v)); s = "[has NaN]"; return; end
        [n,m] = size(v);
        if nargin < 2
            r = 3 + 7*(m<2);
        end
        v = round(mean(v,1),r);
        v(abs(v)>1e3) = inf.*v(abs(v)>1e3);
        s = join(string(v),',');
        flag = '[]';
        if n == 1; flag = '()'; end
        if m <  2; flag = '';   end
        switch flag
            case '()';s = "(" + s + ")";
            case '[]';s = "[" + s + "]";
            case '{}';s = "[" + s + "]";
        end
    end
end

methods (Abstract)
	value(o) % current value: positions matrix or a struct
    update(o,~)
end

methods (Access=public,Static,Hidden)

    function [position,args] = extractPosition(args,maxpositions)
        if nargin <2; maxpositions = 1; end
        if ~isempty(args) && isnumeric(args{1}) && (maxpositions==1 && numel(args{1})==2 ||...
                                      size(args{1},1)<=maxpositions && size(args{1},2)==2)
            position = args{1};
            args = args(2:end);
        else
            position = [];
        end
    end
    
    function [text,args] = extractText(args)
        if ~isempty(args) && (size(args{1},1)==1 && ischar(args{1}) || isStringScalar(args{1}) )
            text = args{1};
            args = args(2:end);
        else
            text = [];
        end
    end

    function b = isColorName(x)
        shorcolnames = 'rgbcmykw';
        if isstring(x) && strlength(x)==1; x=char(x); end
        longcolnames = ["red","green","blue","cyan","magenta","yellow","black","white"];
        b = isnumeric(x) && (length(x)==3) ||...
            ischar(x) && (length(x)==1) && any(x==shorcolnames) || ...
            (isstring(x) || ischar(x)) && any(strcmp(x,longcolnames));
    end

    function mustBeColor(x)
        if ~(drawing.isColorName(x) || isnumeric(x) && numel(x)==3)
            eidType = 'mustBeColor:notColor';
            msgType = 'Invalid color';
            throwAsCaller(MException(eidType,msgType));            
        end
    end

    function mustBeInputList(x,parent)
        if ~iscell(x)
            eidType = 'mustBeInputList:notCell';
            msgType = 'The input list of dependent drawings be a cell array.';
            throwAsCaller(MException(eidType,msgType));
        end
        for i = 1:length(x)
            h = x{i};
            if size(h,1)==1 && ischar(h) || isStringScalar(h)
                if ~isvarname(h)
                    eidType = 'mustBeInputList:notVariableName';
                    msgType = ['The input label ''' h ''' is not a valid variable name.'];
                    throwAsCaller(MException(eidType,msgType));
                end
                if ~parent.isLabel(h)
                    eidType = 'mustBeInputList:labelNotFound';
                    msgType = ['The input label ''' h ''' does not exist.'];
                    throwAsCaller(MException(eidType,msgType));
                end
            elseif ~isa(h,'drawing')
                eidType = 'mustBeInputList:invalidType';
                msgType = 'The input label is of invalid type or size.';
                throwAsCaller(MException(eidType,msgType));
            end
        end
    end

    function labels = getHandlesOfLabels(o,x)
        labels = cell(1,length(x));
        for i=1:length(x)
            if isa(x{i},'drawing')
                labels{i} = x{i};
            else
                labels{i} = o.getHandle(x{i});
            end
        end
    end

    function b = isInputPatternMatching(inputs,pattern)
        if length(inputs) ~= length(pattern)
            b = false;
        else
            b = true;
            for i = 1:length(inputs)
                pat = pattern{i};
                in = inputs{i};
                if iscell(pat)
                    b2 = false;
                    for j=1:length(pat)
                        b2 = b2 || isa(in,pat{j});
                    end
                    b = b && b2;
                else
                    b = b && isa(in,pat);
                end
            end            
        end
    end
    
    function [b,varargout] = matchLineSpec( spec )
        varargout = cell(1,3);
        if (~ischar(spec) && ~isstring(spec)) || strlength(spec) == 0
            b = false;
            return;
        end
        exs = cell(1,3);
        exs{1} = '^(-[-.]?|:|\.-)';
        exs{2} = '^([o+*.x_|^v><]|s(q(u(a(re?)?)?)?)?|d(i(a(m(o(nd?)?)?)?)?)?|p(e(n(t(a(g(r(am?)?)?)?)?)?)?)?|h(e(x(a(g(r(am?)?)?)?)?)?)?)';
        exs{3} = '^(r(ed?)?|g(r(e(en?)?)?)?|b(l(ue?)?)?|c(y(an?)?)?|m(a(g(e(n(ta?)?)?)?)?)?|y(e(l(l(ow?)?)?)?)?|(blac)?k|bla|blac|w(h(i(te?)?)?)?)';

        for k = 1:3
            for i=1:3
                if exs{i} == 0
                    continue;
                end
                m = regexp(spec,exs{i},'match','once');
                if size(m,1) == 1
                    varargout{i} = m;
                    exs{i} = 0;
                    spec = extractAfter(spec,strlength(m));
                    break;
                end
            end
            if strlength(spec) == 0
                break;
            end
        end
        b = strlength(spec) == 0;
    end

    function mustBeLineSpec(spec)
        if ~(size(spec,1)==1 && ischar(spec) || isStringScalar(spec))
            eidType = 'mustBeLineSpec:notString';
            msgType = 'Line style specification must be a string';
            throwAsCaller(MException(eidType,msgType));
        end
        if ~drawing.matchLineSpec(spec)
            eidType = 'mustBeLineSpec:notLineSpec';
            msgType = ['Line style specification ''' spec ''' is invalid.'];
            throwAsCaller(MException(eidType,msgType));
        end
    end

    function mustBeOfLength(val,len)
        if length(val)~=len
            eidType = 'mustBeOfLength:wrongLength';
            msgType = ['Length of input array is not ' int2str(len) '.'];
            throwAsCaller(MException(eidType,msgType));        
        end
    end
end
end