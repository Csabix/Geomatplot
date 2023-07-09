classdef (Abstract) dependent < drawing
properties
	labels (1,:) cell
	callback
    runtime (1,1) double = 0
    movs
end
methods

    function o = dependent(parent,label,labels,callback)
        o = o@drawing(parent,label,[]);
        o.labels = labels;
        o.callback = callback;
        o.parent.deps.(label)=o;
        o.addCallbacks(labels);
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
        tic; args = cell(1,length(o.labels));
        for i = 1:length(o.labels)
            args{i} = o.labels{i}.value;
        end
        outs = cell(1,abs(nargout(o.callback)));
        [outs{:}] = o.callback(varargin{:},args{:});
        ret = o.parseOutputs(outs);
        o.runtime = 0.5*(toc+o.runtime);
    end
    
    function update(o,~)
        ret = o.call;
        o.updatePlot(ret{:});
    end

end
methods (Abstract)
    updatePlot(o,varargin)
end
methods (Abstract,Static)
	parseOutputs(args)
end
end