classdef dscalar < dnumeric
properties
    val % (1,1) double
end
methods
    function c = plus(a,b)
        arguments
            a   (1,1) {mustBeA(a,["dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["dscalar","numeric"])}
        end
        [parent,inputs,callback] = point_base.assembleCallbackOp(a,b,'+',[1 1]);
        c = dscalar(parent,parent.getNextLabel('small'),inputs,callback);
    end
    function c = minus(a,b)
        arguments
            a   (1,1) {mustBeA(a,["dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["dscalar","numeric"])}
        end
        [parent,inputs,callback] = point_base.assembleCallbackOp(a,b,'-',[1 1]);
        c = dscalar(parent,parent.getNextLabel('small'),inputs,callback);
    end
    function c = mtimes(a,b)
        arguments
            a   (1,1) {mustBeA(a,["dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["dscalar","numeric"])}
        end
        [parent,inputs,callback] = point_base.assembleCallbackOp(a,b,'*',[1 1]);
        c = dscalar(parent,parent.getNextLabel('small'),inputs,callback);
    end
    function c = mrdivide(a,b)
        arguments
            a   (1,1) {mustBeA(a,["dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["dscalar","numeric"])}
        end
        [parent,inputs,callback] = point_base.assembleCallbackOp(a,b,'/',[1 1]);
        c = dscalar(parent,parent.getNextLabel('small'),inputs,callback);
    end
    function c = mpower(a,b)
        arguments
            a   (1,1) {mustBeA(a,["dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["dscalar","numeric"])}
        end
        [parent,inputs,callback] = point_base.assembleCallbackOp(a,b,'^',[1 1]);
        c = dscalar(parent,parent.getNextLabel('small'),inputs,callback);
    end
end
end