classdef (Abstract) dependent < drawing
properties
	inputs    (1,:) cell
	callback  (1,1)
    movs      (1,1) struct
    exception            = []
    hidden    (1,1) logical = false % sets fig.Visible = 'off' on update
end
properties (Hidden)
    runtimes (1,12) double = zeros(1,12);
end
properties (Hidden, Dependent)
    last_total_time      (1,1) double;
    last_callb_time      (1,1) double;
    last_parse_time      (1,1) double;
    last_plots_time      (1,1) double;
    move_total_time (1,1) double;
    move_callb_time (1,1) double;
    move_parse_time (1,1) double;
    move_plots_time (1,1) double;
    stop_total_time (1,1) double;
    stop_callb_time (1,1) double;
    stop_parse_time (1,1) double;
    stop_plots_time (1,1) double;
end
methods % get/set
    function v = get.last_total_time(o); v = o.runtimes( 1);     end
    function v = get.last_callb_time(o); v = o.runtimes( 2);     end
    function v = get.last_parse_time(o); v = o.runtimes( 3);     end
    function v = get.last_plots_time(o); v = o.runtimes( 4);     end
    function v = get.move_total_time(o); v = o.runtimes( 5);     end
    function v = get.move_callb_time(o); v = o.runtimes( 6);     end
    function v = get.move_parse_time(o); v = o.runtimes( 7);     end
    function v = get.move_plots_time(o); v = o.runtimes( 8);     end
    function v = get.stop_total_time(o); v = o.runtimes( 9);     end
    function v = get.stop_callb_time(o); v = o.runtimes(10);     end
    function v = get.stop_parse_time(o); v = o.runtimes(11);     end
    function v = get.stop_plots_time(o); v = o.runtimes(12);     end
    function     set.last_total_time(o,v);   o.runtimes( 1) = v; end
    function     set.last_callb_time(o,v);   o.runtimes( 2) = v; end
    function     set.last_parse_time(o,v);   o.runtimes( 3) = v; end
    function     set.last_plots_time(o,v);   o.runtimes( 4) = v; end
end

methods
    function o = dependent(parent,label,fig,inputs,callback,hidden)
        o = o@drawing(parent,label,fig);
        o.inputs = inputs;
        o.parent.deps.(label)=o;
        o.hidden = hidden;
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
        if ~isempty(o.exception)
            warning(o.exception.message);
            % rethrow(o.exception);
        end
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
        if o.defined % only false if inputs were undefined
            outs = cell(1,abs(nargout(o.callback)));
            ts = tic;                        % (((
            try
                [outs{:}] = o.callback(varargin{:},o.inputs{:});
            catch ME
                o.defined = false;
                o.exception = ME;
            end
            o.last_callb_time = toc(ts);     % )))
            if o.defined
                ts = tic;                    % (((
                ret = o.parseOutputs(outs);
                o.last_parse_time = toc(ts); % )))
                ts = tic;                    % (((
                o.updatePlot(ret{:});
                o.last_plots_time = toc(ts); % )))
            end
        end
        if o.defined && ~o.hidden
            o.fig.Visible = 'on';
        else
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