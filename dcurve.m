classdef dcurve < dlines
    methods
        function o = dcurve(parent,label,labels,callback,args)
            t=linspace(0,1)';
            o=o@dlines(parent,label,labels,callback,args,t);
        end
        function update(o,evt)
            t = linspace(0,1)';
            ret = o.call(t);
            o.updatePlot(ret{:});
        end
    end

end