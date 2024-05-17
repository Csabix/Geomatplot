classdef escalar < expression_base

methods
    function c = plus(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","scalar_base","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","scalar_base","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'+',[1 1]);
        c = escalar(parent,inputs,constants,expression,operator);
    end
    function c = minus(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","scalar_base","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","scalar_base","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'-',[1 1]);
        c = escalar(parent,inputs,constants,expression,operator);
    end
    function c = times(a,b)
        c = mtimes(a,b);
    end
    function c = mtimes(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","scalar_base","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","scalar_base","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'*',[1 1]);
        c = escalar(parent,inputs,constants,expression,operator);
    end
    function c = mrdivide(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","scalar_base","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","scalar_base","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'/',[1 1]);
        c = escalar(parent,inputs,constants,expression,operator);
    end
    function c = power(a,b)
        c = mpower(a,b);
    end
    function c = mpower(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","scalar_base","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","scalar_base","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'^',[1 1]);
        c = escalar(parent,inputs,constants,expression,operator);
    end
    function d = evalimpl(o,label)
        [inputs,callback] = o.createCallback();
        d = dscalar(o.parent,label,inputs,callback);
    end
end
methods (Static)
    function s = fromDrawing(d)
        arguments
            d (1,1) scalar_base
        end
        s = escalar(d.parent, {d}, {}, d.label);
    end
end
end

