classdef dtext < dependent
    properties
        offset (1,1) double
    end
methods
    function o = dtext(parent,label,inputs,callback,args,offset)
        args = namedargs2cell(args);
        fig = text(0,0,'',args{:});
        o = o@dependent(parent,label,fig,inputs,[]);
        o.offset = offset;
        o.callback = callback;
        o.addCallbacks(o.inputs);
        o.update;
        if ~isempty(o.exception); rethrow(o.exception); end
    end
    function updatePlot(o,pos,text)
        if o.offset == 0
            o.fig.String = text;
        else
            if strcmp(o.fig.Interpreter,'latex')
                padding = ['\hspace{' num2str(o.offset*.3) 'em}'];
            else
                padding = blanks(o.offset);
            end
            if ischar(text)
                o.fig.String = [padding text];
            else
                o.fig.String = padding + text; 
            end
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

