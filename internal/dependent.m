classdef (Abstract) dependent < drawing
properties
	inputs    (1,:) cell
	callback  (1,1)
    movs
    exception            = []
end
methods

    function o = dependent(parent,label,fig,inputs,callback)
        o = o@drawing(parent,label,fig);
        o.inputs = inputs;
        o.parent.deps.(label)=o;
        if ~isempty(callback)
            o.callback = callback;
            o.addCallbacks(o.inputs);
            o.update;
            if ~isempty(o.exception); rethrow(o.exception); end
        end
    end

    function update(o,~)
        o.call;
    end
end

methods (Access = protected)

    function addCallbacks(o,inputs)
        for i = 1:length(inputs)
            h = inputs{i};
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

    function call(o,varargin)
        tic; o.defined = true;
        try
            outs = cell(1,abs(nargout(o.callback)));
            [outs{:}] = o.callback(varargin{:},o.inputs{:});
        catch ME
            o.defined = false;
            o.exception = ME;
        end
        if o.defined
            ret = o.parseOutputs(outs);
            o.updatePlot(ret{:});
            o.runtime = 0.5*(toc+o.runtime);
            o.fig.Visible = 'on';
        else
            [~] = toc;
            o.fig.Visible = 'off';
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