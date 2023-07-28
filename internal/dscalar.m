classdef dscalar < dnumeric
properties
    val % (1,1) double
end
methods
    function c = plus(a,b)
        c = dscalar.operator(a,b,@plus);
    end
    function c = minus(a,b)
        c = dscalar.operator(a,b,@minus);
    end
    function c = times(a,b)
        c = dscalar.operator(a,b,@times);
    end
    function c = power(a,b)
        c = dscalar.operator(a,b,@power);
    end
    function c = rdivide(a,b)
        c = dscalar.operator(a,b,@rdivide);
    end
end
methods (Access=private,Static)
    function c = operator(a,b,op)
        if isa(b,'dscalar') && isa(a,'dscalar')
            assert(a.parent==b.parent);
            c = dscalar(a.parent,a.parent.getNextLabel('small'),{a,b},@(a,b) op(a.value,b.value));
        elseif isa(b,'dscalar')
            c = dscalar(b.parent,b.parent.getNextLabel('small'),{b},@(b) op(a,b.value));
        else
            c = dscalar(a.parent,a.parent.getNextLabel('small'),{a},@(a) op(a.value,b));
        end
    end
end
end