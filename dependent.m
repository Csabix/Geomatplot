classdef (Abstract) dependent < drawing
properties
	labels (1,:) cell
	callback
    runtime (1,1) double = 0
end
methods

    function o=dependent(parent,label,labels,callback)
        o = o@drawing(parent,label);
        o.labels = labels;
        o.callback = callback;
        o.parent.deps.(label)=o;
        callfun = @(~,evt) o.update(evt);
        o.addCallback(callfun);
    end

    function ret = call(o)
        tic; args = cell(1,length(o.labels));
        for i = 1:length(o.labels)
            args{i} = o.labels{i}.value;
        end
        outs = cell(1,abs(nargout(o.callback)));
        [outs{:}] = o.callback(args{:});
        ret = o.parseOutputs(outs);
        o.runtime = 0.5*(toc+o.runtime);
    end
    function update(o,evt)
        ret = o.call;
        o.updatePlot(ret{:});
    end

    function addCallback(o,callback)
        for i=1:length(o.labels)
            h = o.labels{i};
            h.addCallback(callback);
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