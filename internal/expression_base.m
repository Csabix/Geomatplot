classdef expression_base
    
properties
	parent     (1,1) Geomatplot
    % only expressions with the same parent can be combined
	inputs     (1,1) struct
    % handles for drawings (scalar, point, vector)
    % `label -> handle` map, for easy merging
    constants  (1,:) cell
    % the constants used in the expression
    % for easy renaming, the constants are named `c@i@`, where i is
    %   the index in the array (so for example `c@1@` `c@2@` `c@3@` ...)
    % when combining two temps into a new expression, the constants
    %   need to be renamed in the expression string
    expression (1,:) char
    % the string of the built expression
    operator   (1,1) char
    % top level operator in the expression
    % helps minimizing the amount of parentheses
end

methods
    function o = expression_base(parent, inputs, constants, expression, operator)
        arguments
            parent     (1,1) Geomatplot
            inputs     (1,:) cell
            constants  (1,:) cell
            expression (1,:) char
            operator   (1,1) char = '^'
        end
        
        o.parent = parent;
        o.inputs = struct;
        for i = 1:length(inputs)
            in = inputs{i};
            assert(isa(in,'drawing') && in.parent == parent);
            o.inputs.(in.label) = in;
        end
        o.constants = constants;
        o.expression = expression;
        o.operator = operator;
    end  
    function val = eval(o,label)
        if nargin < 2
            label = o.parent.getNextLabel('expr');
        else
            assert(isvarname(label));
        end
        val = o.evalimpl(label);
    end
    function v = ctranspose(o)
        v = o.eval;
    end
end
methods (Static, Hidden)
    function warning_if_unused(numargs)
        if numargs ~= 1
            warning('Unused expression - if you meant to create a dependent object, call eval() or ()'' on the expression');
        end
    end
end
methods (Hidden)
    function [inputs,callback] = createCallback(o)
        inputs = struct2cell(o.inputs);
        f = fieldnames(o.inputs);
        args = join(f,',');
        args = args{1};
        exp = o.expression;
        exp = expression_base.substituteConstants(exp, o.constants);
        exp = replace(exp, f, f + ".value");
        callbackStr = ['@(' args ')' exp];
        callback = eval(callbackStr);
    end
end
methods (Access = protected, Static, Hidden)

    function label = constLabel(index)
        if isscalar(index)
            label = ['c@' num2str(index) '@'];
        else
            label = "c@" + index + "@";
        end
    end
    function a = wrapIfNotExpression(a,b,sz)
        if ~isa(a,'expression_base')
            if isa(a,'drawing')
                assert(isscalar(a),'invalid operand');
                a = expression_base(a.parent, {a}, {}, a.label);
            elseif isa(b,'drawing') || isa(b,'expression_base')
                assert(all(size(a) == sz) || all(size(a)==[2 2]),'invalied constant');
                a = expression_base(b.parent, {}, {a}, expression_base.constLabel(1));
            else
                throw('invalid operation');
            end
        end
    end
    function exp = renameConstants(exp, indsForm, indsTo)
        exp = replace(exp, expression_base.constLabel(indsForm), expression_base.constLabel(indsTo));
    end
    function exp = substituteConstants(exp, constants)
        n = length(constants);
        names = expression_base.constLabel(1:n);
        function w = writeConst(c)
            if isscalar(c)
                w = num2str(c);
            elseif numel(c) == 2
                w = num2str(c(:)','[%.10f %.10f]');
            elseif all(size(c)==[2 2])
                w = num2str(c(:)','[%.10f %.10f;%.10f %.10f]');
            else
                throw('wrong constant');
            end
        end
        vals = cellfun(@writeConst,constants,'UniformOutput',false);
        exp = replace(exp, names, vals);
    end
    function [parent,inputs,constants,expression,operator] = assembleExpression(a,b,operator,sz)
        a = expression_base.wrapIfNotExpression(a,b,sz);
        b = expression_base.wrapIfNotExpression(b,a,sz);
        % parent
        assert(a.parent == b.parent, 'different Geomatplots');
        parent = a.parent;
        % inputs
        inputs = a.inputs;
        f = fieldnames(b.inputs); % merge structs
        for j = 1:length(f)
            inputs.(f{j}) = b.inputs.(f{j});
        end
        inputs = struct2cell(inputs);
        % constants
        constants = [a.constants b.constants];
        % expression
        aexp = a.expression;
        bexp = b.expression;
        ca = length(a.constants);
        cb = length(b.constants);
        if ca ~= 0 && cb ~= 0
            bexp = expression_base.renameConstants(bexp, 1:cb, (ca+1):(ca+cb));
        end
        if length(a.constants) + length(fieldnames(a.inputs)) > 1
            aexp = ['(' aexp ')'];
        end
        if length(b.constants) + length(fieldnames(b.inputs)) > 1
            bexp = ['(' bexp ')'];
        end
        expression = [aexp ' ' operator ' ' bexp];
    end
end
end

