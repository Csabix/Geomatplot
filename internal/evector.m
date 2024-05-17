classdef evector < expression_base

methods
    function c = plus(a,b)
        arguments
            a   (1,:) {mustBeA(a,["evector","dvector","numeric"])}
            b   (1,:) {mustBeA(b,["evector","dvector","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'+',[1 2]);
        c = evector(parent,inputs,constants,expression,operator);
    end
    function c = minus(a,b)
        arguments
            a   (1,:) {mustBeA(a,["evector","dvector","numeric"])}
            b   (1,:) {mustBeA(b,["evector","dvector","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'-',[1 2]);
        c = evector(parent,inputs,constants,expression,operator);
    end
    function c = times(a,b)
        c = mtimes(a,b);
    end
    function c = mtimes(a,b)
        arguments
            a   (1,1) {mustBeA(a,["evector","dvector","escalar","scalar_base","numeric"])}
            b   (1,1) {mustBeA(b,["evector","dvector","escalar","scalar_base","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        a_is_vector = isa(a,'dvector')||isa(a,'evector');
        b_is_vector = isa(b,'dvector')||isa(b,'evector');
        assert(~a_is_vector || ~b_is_vector,'invalid input');
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'*',[1 1]);
        c = evector(parent,inputs,constants,expression,operator);
    end
    function c = mrdivide(a,b)
        arguments
            a   (1,1) {mustBeA(a,["evector","dvector","escalar","scalar_base","numeric"])}
            b   (1,1) {mustBeA(b,["evector","dvector","escalar","scalar_base","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        a_is_vector = isa(a,'dvector')||isa(a,'evector');
        b_is_vector = isa(b,'dvector')||isa(b,'evector');
        assert(~a_is_vector || ~b_is_vector,'invalid input');
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'/',[1 1]);
        c = evector(parent,inputs,constants,expression,operator);
    end
    function d = evalimpl(o,label)
        [inputs,callback] = o.createCallback();
        d = dvector(o.parent,label,inputs,callback);
    end
end
methods (Static)
    function s = fromDrawing(d)
        arguments
            d (1,1) dvector
        end
        s = evector(d.parent, {d}, {}, d.label);
    end
end
end

