classdef dpoint < dependent
methods
    function o = dpoint(parent,label,labels,callback,args)
        o = o@dependent(parent,label,labels,callback);
        ret = o.call;
        o.fig = drawpoint('InteractionsAllowed','none',args{:},'Position',ret{1});
        o.fig.UserData = o;
    end
    function v = value(o)
        v = o.fig.Position;
    end
    function updatePlot(o,pos)
        o.fig.Position = pos;
    end
end
methods (Static)
    function outs = parseOutputs(args)
        if length(args)==1
            outs{1} = args{1};
        elseif length(args)==2
            outs{1} = [args{1}(:) args{2}(:)];
        else
            error 'Callback has too many outputs.'
        end
    end
end
end