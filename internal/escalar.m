classdef escalar < expression_base

methods
    function c = plus(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","dscalar","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'+',[1 1]);
        c = escalar(parent,inputs,constants,expression,operator);
    end
    function c = minus(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","dscalar","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'-',[1 1]);
        c = escalar(parent,inputs,constants,expression,operator);
    end
    function c = mtimes(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","dscalar","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'*',[1 1]);
        c = escalar(parent,inputs,constants,expression,operator);
    end
    function c = mrdivide(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","dscalar","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'/',[1 1]);
        c = escalar(parent,inputs,constants,expression,operator);
    end
    function c = mpower(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","dscalar","numeric"])}
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
            d (1,1) dscalar
        end
        s = escalar(d.parent, {d}, {}, d.label);
    end
end
end

