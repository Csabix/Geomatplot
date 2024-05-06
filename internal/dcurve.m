classdef dcurve < dlines
    properties
        Resolution (1,1) double = 512;
    end
    methods
        function o = dcurve(parent,label,inputs,callback,params,resolution)
            if nargin >= 6
                params.SizeOverride = resolution;
            else
                params.SizeOverride = 512;
            end
            o = o@dlines(parent,label,inputs,[],params);
            if nargin >= 6; o.Resolution = resolution; end
            o.setUpdateCallback(callback);
        end
        function update(o,~)
            t = linspace(0,1,o.Resolution)';
            o.call(t);
        end
    end
end