classdef dscalar < dnumeric
properties
    val % (1,1) double
end
methods
    function c = plus(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","dscalar","numeric"])}
        end
        if isa(a,'dscalar'); a = escalar.fromDrawing(a);
        elseif isa(b,'dscalar'); b = escalar.fromDrawing(b); end
        c = a + b;
    end
    function c = minus(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","dscalar","numeric"])}
        end
        if isa(a,'dscalar'); a = escalar.fromDrawing(a);
        elseif isa(b,'dscalar'); b = escalar.fromDrawing(b); end
        c = a - b;
    end
    function c = mtimes(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","dscalar","numeric"])}
        end
        if isa(a,'dscalar'); a = escalar.fromDrawing(a);
        elseif isa(b,'dscalar'); b = escalar.fromDrawing(b); end
        c = a * b;
    end
    function c = mrdivide(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","dscalar","numeric"])}
        end
        if isa(a,'dscalar'); a = escalar.fromDrawing(a);
        elseif isa(b,'dscalar'); b = escalar.fromDrawing(b); end
        c = a / b;
    end
    function c = mpower(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","dscalar","numeric"])}
        end
        if isa(a,'dscalar'); a = escalar.fromDrawing(a);
        elseif isa(b,'dscalar'); b = escalar.fromDrawing(b); end
        c = a ^ b;
    end
end
end