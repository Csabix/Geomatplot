classdef dtext < dependent
methods
    function o = dtext(parent,label,inputs,callback,args)
        args = namedargs2cell(args);
        fig = text(0,0,'',args{:});
        o = o@dependent(parent,label,fig,inputs,callback);
    end
    function updatePlot(o,pos,text)
        o.fig.String = text;
        o.fig.Position = pos;
    end
    function text = value(o)
        text = o.fig.String;
    end
end
methods (Static)
    function args = parseOutputs(args)
        if length(args)~=2
            error 'Callback has the wrong number of outputs.'
        end
    end
end
end

