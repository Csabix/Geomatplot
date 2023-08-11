classdef (Abstract) dependent < drawing
properties
	inputs    (1,:) cell
	callback  (1,1)
    movs      (1,1) struct
    exception            = []
end
methods

    function o = dependent(parent,label,fig,inputs,callback)
        o = o@drawing(parent,label,fig);
        o.inputs = inputs;
        o.parent.deps.(label)=o;
        if ~isempty(callback)
            o.setUpdateCallback(callback);
        end
    end

    function update(o,~)
        o.call;
    end

    function s = string(o,varargin)
        if isempty(o.exception)
            s = string@drawing(o,varargin{:});
        else
            s = "UNDEFINED";
        end
    end
end

methods (Access = public, Hidden)
    function s = getCallbackStr(o)
        s = replace(func2str(o.callback),'.value','');
        if (isa(o,'dvector') || isa(o,'dpoint')) && length(o.label) > 4 && strcmp(o.label(1:4),'expr')
            % do nothing
        else
            ls = "";
            for i = 1:length(o.inputs)
                ls = ls + o.inputs{i}.label;
                if i < length(o.inputs); ls = ls+','; end
            end
            if s(1) ~= '@'
                s = s + "(" + ls + ")";
            else
                s = "f(" + ls + ") f=" + s;
            end
        end
    end
end

methods (Access = protected)
    
    % If you dont want dependent constructor to call update yet,
    % call this after pasing [] as a callback to the constructor.
    function setUpdateCallback(o,callback,inputs)
        if nargin < 3; inputs = o.inputs; end
        o.addCallbacks(inputs);
        o.callback = callback;
        o.update;
        if ~isempty(o.exception); rethrow(o.exception); end
    end

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