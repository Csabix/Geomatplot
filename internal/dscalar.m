classdef dscalar < dependent
properties
    val (:,:) double
end
methods
    function o=dscalar(parent,label,inputs,callback)
        o@dependent(parent,label,struct,inputs,callback);
    end
    function v = value(o)
        v = o.val;
    end
    function updatePlot(o,val)
        o.val = val;
    end
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
methods (Static)
    function args = parseOutputs(args)
        if isempty(args)
            error 'Callback has no outputs.'
        elseif length(args)>1
            error 'Callback has more then one output.'
        end
    end
end
end