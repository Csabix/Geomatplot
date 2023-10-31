classdef dcustomvalue < dependent
properties
    val
end
methods
    function o=dcustomvalue(parent,label,inputs,callback,hidden)
        if nargin < 5
            hidden = false;
        end
        o@dependent(parent,label,struct,inputs,callback,hidden);
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
            error 'Callback has more than one output.'
        end
    end
end
end