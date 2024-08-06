classdef epoint < expression_base

methods
    function c = plus(a,b)
        arguments
            a   (1,:) {mustBeA(a,["point_base","epoint","dvector","evector","numeric"])}
            b   (1,:) {mustBeA(b,["point_base","epoint","dvector","evector","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        a_is_point = isa(a,'point_base')||isa(a,'epoint');
        b_is_point = isa(b,'point_base')||isa(b,'epoint');
        assert(~a_is_point || ~b_is_point, 'invalid input');
        [parent,inputs,constants,expression] = expression_base.assembleExpression(a,b,'+',[1 2]);
        c = epoint(parent,inputs,constants,expression);
    end
    function c = minus(a,b)
        arguments
            a   (1,:) {mustBeA(a,["point_base","epoint","dvector","evector","numeric"])}
            b   (1,:) {mustBeA(b,["point_base","epoint","dvector","evector","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        a_is_point = isa(a,'point_base')||isa(a,'epoint')||isnumeric(a);
        b_is_point = isa(b,'point_base')||isa(b,'epoint');
        [parent,inputs,constants,expression] = expression_base.assembleExpression(a,b,'-',[1 2]);
        if a_is_point && b_is_point
            c = evector(parent,inputs,constants,expression);
        else
            assert(~b_is_point,'invalid operation');
            c = epoint(parent,inputs,constants,expression);
        end
    end
    function d = evalimpl(o,label)
        [inputs,callback] = o.createCallback();
        d = dpoint(o.parent,label,inputs,callback);
    end
end
methods (Static)
    function s = fromDrawing(d)
        arguments
            d (1,1) point_base
        end
        s = epoint(d.parent, {d}, {}, d.label);
    end
end
end

