classdef expression_base
    
properties
	parent     (1,1) Geomatplot
	inputs     (1,1) struct
    constants  (1,:) cell
    expression (1,:) char
    operator   (1,1) char % top level operator in the expression
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
methods (Access = protected, Hidden)
    function [inputs,callback] = createCallback(o)
        inputs = struct2cell(o.inputs);
        f = fieldnames(o.inputs);
        args = join(f,',');
        args = args{1};
        exp = o.expression;
        exp = replace(exp, f, f + ".value");
        exp = expression_base.substituteConstants(exp, o.constants);
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
                assert(all(size(a) == sz),'invalied constant');
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
            elseif length(c) == 2
                w = num2str(c,'[%.10f %.10f]');
            else
                throw('wrong constant');
            end
        end
            disp(constants);
        vals = cellfun(@writeConst,constants,'UniformOutput',false);
        exp = replace(exp, names, vals);
    end
    function p = operatorPrecedence(op)
        switch op
            case '+'; p = 1;
            case '-'; p = 1;
            case '*'; p = 2;
            case '/'; p = 2;
            case '^'; p = 3;
        end
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
        prec = expression_base.operatorPrecedence(operator);
        if expression_base.operatorPrecedence(a.operator) < prec
            aexp = ['(' aexp ')'];
        end
        if expression_base.operatorPrecedence(b.operator) < prec
            bexp = ['(' bexp ')'];
        end
        expression = [aexp ' ' operator ' ' bexp];
    end
end
end

