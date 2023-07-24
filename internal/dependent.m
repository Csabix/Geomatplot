classdef (Abstract) dependent < drawing
properties
	inputs (1,:) cell
	callback
    movs
end
methods

    function o = dependent(parent,label,inputs,callback)
        o = o@drawing(parent,label,[]);
        o.inputs = inputs;
        o.callback = callback;
        o.parent.deps.(label)=o;
        o.addCallbacks(o.inputs);
    end

    function addCallbacks(o,labels)
        for i = 1:length(labels)
            h = labels{i};
            if isa(h,'moveable')
                o.movs.(h.label) = h;
            else
                f = fieldnames(h.movs); % merge structs
                for j = 1:length(f)
                    o.movs.(f{j}) = h.movs.(f{j});
                end
            end
        end
        values = struct2cell(o.movs);
        for i = 1:length(values)
            values{i}.addCallback(o);
        end
    end

    function ret = call(o,varargin)
        tic; args = cell(1,length(o.inputs));
        for i = 1:length(o.inputs)
            args{i} = o.inputs{i}.value;
        end
        o.defined = true;
        try
            outs = cell(1,abs(nargout(o.callback)));
            [outs{:}] = o.callback(varargin{:},args{:});
        catch
            o.defined = false;
        end
        if o.defined
            ret = o.parseOutputs(outs);
            o.runtime = 0.5*(toc+o.runtime);
            o.fig.Visible = 'on';
        else
            ret = []; [~] = toc;
            o.fig.Visible = 'off';
        end
    end
    
    function update(o,~)
        ret = o.call;
        if o.defined
            o.updatePlot(ret{:});
        end
    end

end
methods (Abstract)
    updatePlot(o,varargin)
end
methods (Abstract,Static)
	parseOutputs(args)
end
end