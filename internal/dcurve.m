classdef dcurve < dlines
    properties
        Resolution (1,1) double = 512;
        fun;
    end
    methods
        function o = dcurve(parent,label,inputs,callback,params,resolution)
            o = o@dlines(parent,label,inputs,[],params);
            if nargin >= 6; o.Resolution = resolution; end
            o.setUpdateCallback(callback);
            o.fun = [];
        end
        function update(o,detail_level)
            if nargin < 2; detail_level = 1; end
            t = linspace(0,1,o.Resolution*detail_level)';
            o.call(t);
        end
        function f = get.fun(o)
            if isempty(o.fun)
                nlabel = o.parent.extractLabel({},'custom');
                o.fun = dcustomvalue(o.parent,nlabel,{o}, @(o) @(t) o.callback(t,o.inputs{:}) );
            end
            f = o.fun;
        end
    end
end