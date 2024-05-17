classdef scalar_base < drawing
methods
    function c = plus(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","scalar_base","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","scalar_base","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        if isa(a,'scalar_base'); a = escalar.fromDrawing(a);
        elseif isa(b,'scalar_base'); b = escalar.fromDrawing(b); end
        c = a + b;
    end
    function c = minus(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","scalar_base","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","scalar_base","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        if isa(a,'scalar_base'); a = escalar.fromDrawing(a);
        elseif isa(b,'scalar_base'); b = escalar.fromDrawing(b); end
        c = a - b;
    end
    function c = times(a,b)
        c = mtimes(a,b);
    end
    function c = mtimes(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","scalar_base","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","scalar_base","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        if isa(a,'scalar_base'); a = escalar.fromDrawing(a);
        elseif isa(b,'scalar_base'); b = escalar.fromDrawing(b); end
        c = a * b;
    end
    function c = mrdivide(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","scalar_base","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","scalar_base","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        if isa(a,'scalar_base'); a = escalar.fromDrawing(a);
        elseif isa(b,'scalar_base'); b = escalar.fromDrawing(b); end
        c = a / b;
    end
    function c = power(a,b)
        c = mpower(a,b);
    end
    function c = mpower(a,b)
        arguments
            a   (1,1) {mustBeA(a,["escalar","scalar_base","numeric"])}
            b   (1,1) {mustBeA(b,["escalar","scalar_base","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        if isa(a,'scalar_base'); a = escalar.fromDrawing(a);
        elseif isa(b,'scalar_base'); b = escalar.fromDrawing(b); end
        c = a ^ b;
    end
end
end

