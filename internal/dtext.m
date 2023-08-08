classdef dtext < dependent
    properties
        offset (1,1) double
    end
methods
    function o = dtext(parent,label,inputs,callback,args,offset)
        args = namedargs2cell(args);
        fig = text(0,0,'',args{:});
        o = o@dependent(parent,label,fig,inputs,callback);
        o.offset = offset;
    end
    function updatePlot(o,pos,text)
        if o.offset == 0
            o.fig.String = text;
        elseif ischar(text)
            o.fig.String = [blanks(o.offset) text];
        else
            o.fig.String = blanks(o.offset) + text; 
        end
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
