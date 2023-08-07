classdef dcurve < dlines
    properties
        Resolution (1,1) double = 256;
    end
    methods
        function o = dcurve(parent,label,inputs,callback,params,resolution)
            o = o@dlines(parent,label,inputs,[],params);
            o.callback = callback;
            if nargin >= 6; o.Resolution = resolution; end
            o.addCallbacks(inputs);
            o.update(1);
            if ~isempty(o.exception); rethrow(o.exception); end
        end
        function update(o,detail_level)
            if nargin < 2; detail_level = 1; end
            t = linspace(0,1,o.Resolution*detail_level)';
            o.call(t);
        end
    end
end