classdef (InferiorClasses = {?dscalar, ?dvector}) point_base  < handle

methods
    function c = plus(a,b)
        arguments
            a   (1,:) {mustBeA(a,["point_base","dvector","numeric"])}
            b   (1,:) {mustBeA(b,["point_base","dvector","numeric"])}
        end
        assert(~isa(a,'point_base') || ~isa(b,'point_base'),'invalid input');
        [parent,inputs,callback] = point_base.assembleCallbackOp(a,b,'+',[1 2]);
        c = dpoint(parent,parent.getNextLabel('capital'),inputs,callback);
    end
    function c = minus(a,b)
        if isa(a,'point_base') && isa(b,'point_base')
            assert(a.parent==b.parent,'different Geomatplots');
            c = dvector(a.parent,a.parent.getNextLabel('small'),{a,b},@(a,b) a.value-b.value);
        else
            [parent,inputs,callback] = point_base.assembleCallbackOp(a,b,'-',[1 2]);
            c = dpoint(parent,parent.getNextLabel('capital'),inputs,callback);
        end
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