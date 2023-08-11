classdef (InferiorClasses = {?dscalar, ?dvector}) point_base  < handle

methods
    function c = plus(a,b)
        arguments
            a   (1,:) {mustBeA(a,["point_base","epoint","dvector","evector","numeric"])}
            b   (1,:) {mustBeA(b,["point_base","epoint","dvector","evector","numeric"])}
        end
        if isa(a,'point_base'); a = epoint.fromDrawing(a);
        elseif isa(b,'point_base'); b = epoint.fromDrawing(b); end
        c = a + b;
    end
    function c = minus(a,b)
        arguments
            a   (1,:) {mustBeA(a,["point_base","epoint","dvector","evector","numeric"])}
            b   (1,:) {mustBeA(b,["point_base","epoint","dvector","evector","numeric"])}
        end
        if isa(a,'point_base'); a = epoint.fromDrawing(a);
        elseif isa(b,'point_base'); b = epoint.fromDrawing(b); end
        c = a - b;
    end
end

methods (Access=public,Static,Hidden)

    function [parent,inputs,callback] = assembleCallbackOp(a,b,op,sz)
        if isnumeric(a)
            assert(all(size(a)==sz) && isscalar(b),'invalid operation');
            parent = b.parent; inputs = {b};
            switch op % so callback is as fast as possible, no extra call.
                case '+'; callback=@(b)a+b.value;
                case '-'; callback=@(b)a-b.value;
                case '*'; callback=@(b)a*b.value;
                case '/'; callback=@(b)a/b.value;
                case '^'; callback=@(b)a^b.value;
            end
        elseif isnumeric(b)
            assert(all(size(b)==sz) && isscalar(a),'invalid operation');
            parent = a.parent; inputs = {a};
            switch op
                case '+'; callback=@(a)a.value+b;
                case '-'; callback=@(a)a.value-b;
                case '*'; callback=@(a)a.value*b;
                case '/'; callback=@(a)a.value/b;
                case '^'; callback=@(a)a.value^b;
            end
        else
            assert(isscalar(a) && isscalar(b) && a.parent==b.parent,'different Geomatplots');
            parent = a.parent; inputs = {a,b};
            switch op
                case '+'; callback=@(a,b)a.value+b.value;
                case '-'; callback=@(a,b)a.value-b.value;
                case '*'; callback=@(a,b)a.value*b.value;
                case '/'; callback=@(a,b)a.value/b.value;
                case '^'; callback=@(a,b)a.value^b.value;
            end
        end
    end
end
end