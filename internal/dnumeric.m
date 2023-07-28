classdef (Abstract) dnumeric < dependent
properties (Abstract)
    val (:,:) double
end
methods
    function o=dnumeric(parent,label,inputs,callback)
        o@dependent(parent,label,struct,inputs,callback);
    end
    function v = value(o)
        v = o.val;
    end
    function updatePlot(o,val)
        o.val = val;
    end
end
methods (Static)
    function args = parseOutputs(args)
        if isempty(args)
            error 'Callback has no outputs.'
        elseif length(args)>1
            error 'Callback has more then one output.'
        end
    end
end
end