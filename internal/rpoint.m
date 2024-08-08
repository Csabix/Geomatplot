classdef rpoint < dependent & mpoint 
methods
    function o = rpoint(parent,label,args)
        o = o@mpoint(parent,label,args)
        hidden = strcmp(args.Visible,'off');
        o.parent.deps.(label)=o;
        o.hidden = hidden;
    end
    function updatePlot(o,pos)
        if ~any(isnan(pos))
            o.fig.Position = pos;
        else
            o.defined = false;
        end
    end
    function setCallback(o, callback, inputs)
        if isempty(inputs) || inputs{1} ~= o
            error 'Fist input of a restricted object needs to be itself.'
        end
        o.inputs = inputs;
        o.setUpdateCallback(callback, inputs);
        o.fig.bringToFront;
    end
end
methods (Static)
    function outs = parseOutputs(args)
        if length(args)==1
            outs{1} = args{1}(:)';
        elseif length(args)==2
            outs{1} = [args{1}(:) args{2}(:)];
        else
            error 'Callback has too many outputs.'
        end
    end
end
end