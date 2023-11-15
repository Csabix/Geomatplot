classdef (Abstract) dnumeric < dcustomvalue
    methods
    function s = string(o,varargin)
        s = string@dependent(o,varargin{:});
    end
end
end