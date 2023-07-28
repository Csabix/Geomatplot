classdef dvector < dnumeric
properties
    val % (1,2) double
end
methods
    function c = plus(a,b)
        c = dvector.operator(a,b,@plus,'dscalar','dscalar',@dvector,'dvector','numeric',@dvector,'numeric','dvector',@dvector,'dvector','point_base',@dpoint);
    end
    function c = minus(a,b)
        c = dvector.operator(a,b,@minus,'dscalar','dscalar',@dvector,'dvector','numeric',@dvector,'numeric','dvector',@dvector,'dvector','point_base',@dpoint);
    end
    function c = times(a,b)
        c = dvector.operator(a,b,@times,'dscalar','dscalar',@dvector,'dvector','numeric',@dvector,'numeric','dvector',@dvector);
    end
    function c = rdivide(a,b)
        c = dvector.operator(a,b,@rdivide,'dscalar','dscalar',@dvector,'dvector','numeric',@dvector,'numeric','dvector',@dvector);
    end
end
methods (Access=public,Static,Hidden)
    function c = operator(a,b,op,atype,btype,constructor)
        arguments
            a
            b
            op (1,1) function_handle
        end
        arguments (Repeating)
            atype (1,:) char
            btype (1,:) char
            constructor (1,1) function_handle
        end
        if isa(a,'drawing')
            if isa(b,'drawing')
                callback = @(a,b) op(a.value,b.value);
                inputs = {a,b};
                assert(a.parent==b.parent)
            else
                callback = @(a) op(a.value,b);
                inputs = {a};
            end
            g = a.parent;
        else
            assert(isa(b,'drawing'));
            callback = @(b) op(a,b.value);
            inputs = {b};
            g = b.parent;
        end
        l = g.getNextLabel('small');
        for i=1:length(atype)
            if isa(a,atype{i}) && isa(b,btype{i})
                c = constructor{i}(g,l,inputs,callback);
                break;
            end
        end
        % todo if matches none
    end
end
end