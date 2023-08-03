classdef (InferiorClasses = {?dscalar}) dvector < dnumeric
properties
    val % (1,2) double
    pt  = [] %  (1,1) dpoint
end
methods
    function o = dvector(parent,label,inputs,callback,pt,linespec,args)
        o=o@dnumeric(parent,label,inputs,callback);
        if nargin >= 5
            o.pt = pt;
            parent.ax.NextPlot ='add';
            args = namedargs2cell(args);
            o.fig = quiver(0,0,0,0,1.,linespec,args{:});
            o.update;
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
            a   (1,:) {mustBeA(a,["dvector","numeric"])}
            b   (1,:) {mustBeA(b,["dvector","numeric"])}
        end
        [parent,inputs,callback] = point_base.assembleCallbackOp(a,b,'+',[1 2]);
        c = dvector(parent,parent.getNextLabel('small'),inputs,callback);
    end
    function c = minus(a,b)
        arguments
            a   (1,:) {mustBeA(a,["dvector","numeric"])}
            b   (1,:) {mustBeA(b,["dvector","numeric"])}
        end
        [parent,inputs,callback] = point_base.assembleCallbackOp(a,b,'-',[1 2]);
        c = dvector(parent,parent.getNextLabel('small'),inputs,callback);
    end
    function c = mtimes(a,b)
        arguments
            a   (1,1) {mustBeA(a,["dvector","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["dvector","dscalar","numeric"])}
        end
        assert(~isa(a,'dvector') || ~isa(b,'dvector'),'invalid input');
        [parent,inputs,callback] = point_base.assembleCallbackOp(a,b,'*',[1 1]);
        c = dvector(parent,parent.getNextLabel('small'),inputs,callback);
    end
    function c = mrdivide(a,b)
        arguments
            a   (1,1) {mustBeA(a,["dvector","dscalar","numeric"])}
            b   (1,1) {mustBeA(b,["dvector","dscalar","numeric"])}
        end
        assert(~isa(a,'dvector') || ~isa(b,'dvector'),'invalid input');
        [parent,inputs,callback] = point_base.assembleCallbackOp(a,b,'/',[1 1]);
        c = dvector(parent,parent.getNextLabel('small'),inputs,callback);
    end
end
end