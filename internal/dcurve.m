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
        function update(o,detail_level)
            if nargin < 2; detail_level = 1; end
            detail_level = 1; % TODO For now
            t = linspace(0,1,o.Resolution*detail_level)';
            o.call(t);
        end
    end
end