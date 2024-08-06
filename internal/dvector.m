classdef (InferiorClasses = {?dscalar}) dvector < dnumeric
properties
    % val  (1,2) double
    pt  = [] %  (1,1) dpoint
end
methods
    function o = dvector(parent,label,inputs,callback,pt,args)
        o=o@dnumeric(parent,label,inputs,callback);
        if nargin >= 5
            o.pt = pt;
            parent.ax.NextPlot ='add';
            args = namedargs2cell(args);
            o.fig = quiver(parent.ax,0,0,0,0,1.,args{:});
            o.update;
            o.fig.UserData = o;
            addlistener(o.fig,'Hit',@dvector.hit);
            if ~isempty(o.exception); rethrow(o.exception); end
        end
    end
    function updatePlot(o,val)
        updatePlot@dnumeric(o,val);
        if ~isempty(o.pt)
            p = o.pt.value;
            o.fig.XData = p(1);   o.fig.YData = p(2);
            o.fig.UData = val(1); o.fig.VData = val(2);
        end
    end
    function c = plus(a,b)
        arguments
            a   (1,:) {mustBeA(a,["evector","dvector","numeric"])}
            b   (1,:) {mustBeA(b,["evector","dvector","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        if isa(a,'dvector'); a = evector.fromDrawing(a);
        elseif isa(b,'dvector'); b = evector.fromDrawing(b); end
        c = a + b;
    end
    function c = minus(a,b)
        arguments
            a   (1,:) {mustBeA(a,["evector","dvector","numeric"])}
            b   (1,:) {mustBeA(b,["evector","dvector","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        if isa(a,'dvector'); a = evector.fromDrawing(a);
        elseif isa(b,'dvector'); b = evector.fromDrawing(b); end
        c = a - b;
    end
    function c = times(a,b)
        c = mtimes(a,b);
    end
    function c = mtimes(a,b)
        arguments
            a   (1,1) {mustBeA(a,["evector","dvector","escalar","dscalar","numeric"])}
            b   (:,:) {mustBeA(b,["evector","dvector","escalar","dscalar","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        if isa(a,'dvector'); a = evector.fromDrawing(a);
        elseif isa(b,'dvector'); b = evector.fromDrawing(b); end
        c = a * b;
    end
    function c = mrdivide(a,b)
        arguments
            a   (1,1) {mustBeA(a,["evector","dvector","escalar","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["evector","dvector","escalar","dscalar","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        if isa(a,'dvector'); a = evector.fromDrawing(a);
        elseif isa(b,'dvector'); b = evector.fromDrawing(b); end
        c = a / b;
    end
    function c = dot(a,b)
        arguments
            a   (1,:) {mustBeA(a,["evector","dvector","numeric"])}
            b   (1,:) {mustBeA(b,["evector","dvector","numeric"])}
        end
        expression_base.warning_if_unused(nargout);
        if isa(a,'dvector'); a = evector.fromDrawing(a);
        elseif isa(b,'dvector'); b = evector.fromDrawing(b); end
        c = dot(a,b);
    end
end
methods(Static,Hidden)
    function hit(fig,~)
        o = fig.UserData;
        o.parent.pushData(o);
    end
end
end