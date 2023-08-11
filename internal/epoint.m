classdef epoint < expression_base

methods
    function c = plus(a,b)
        arguments
            a   (1,:) {mustBeA(a,["point_base","epoint","dvector","evector","numeric"])}
            b   (1,:) {mustBeA(b,["point_base","epoint","dvector","evector","numeric"])}
        end
        a_is_point = isa(a,'point_base')||isa(a,'epoint');
        b_is_point = isa(b,'point_base')||isa(b,'epoint');
        assert(~a_is_point || ~b_is_point, 'invalid input');
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'+',[1 2]);
        c = epoint(parent,inputs,constants,expression,operator);
    end
    function c = minus(a,b)
        arguments
            a   (1,:) {mustBeA(a,["point_base","epoint","dvector","evector","numeric"])}
            b   (1,:) {mustBeA(b,["point_base","epoint","dvector","evector","numeric"])}
        end
        a_is_point = isa(a,'point_base')||isa(a,'epoint');
        b_is_point = isa(b,'point_base')||isa(b,'epoint');
        [parent,inputs,constants,expression,operator] = expression_base.assembleExpression(a,b,'-',[1 2]);
        if a_is_point && b_is_point
            c = evector(parent,inputs,constants,expression,operator);
        else
            c = epoint(parent,inputs,constants,expression,operator);
        end
    end
    function d = ctranspose(o)
        [inputs,callback] = o.createCallback();
        d = dpoint(o.parent,o.parent.getNextLabel('capital'),inputs,callback);
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

