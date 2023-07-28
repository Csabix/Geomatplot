classdef dcurve < dlines
    methods
        function o = dcurve(parent,label,inputs,linespec,callback,args)
            t = linspace(0,1,256)';
            o = o@dlines(parent,label,inputs,linespec,callback,args,t);
        end
        function update(o,detail_level)
            if nargin < 2; detail_level = 1; end
            t = linspace(0,1,256*detail_level)';
            o.call(t);
        end
    end
end