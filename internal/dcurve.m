classdef dcurve < dlines
    methods
        function o = dcurve(parent,label,inputs,linespec,callback,args)
            t = linspace(0,1,256)';
            o = o@dlines(parent,label,inputs,linespec,callback,args,t);
        end
        function update(o,detail_level)
            t = linspace(0,1,256*detail_level)';
            ret = o.call(t);
            o.updatePlot(ret{:});
        end
    end
end