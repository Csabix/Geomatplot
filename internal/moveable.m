classdef (Abstract) moveable < drawing % with ROI
properties
    deps  % struct mapping label -> dependent class handles
end
properties (Hidden)
    move_total_time (1,1) double = 0;
    stop_total_time (1,1) double = 0;
    move_timing_num (1,1) double = 0;
    stop_timing_num (1,1) double = 0;
end
methods
    function o = moveable(parent,label,fig)
        o = o@drawing(parent,label,fig);
        o.parent.movs.(label) = o;
        o.fig.UserData = o;
        o.deps = struct;
        addlistener(o.fig,'ROIMoved' ,@moveable.update); % todo @update ?
        addlistener(o.fig,'MovingROI',@moveable.update);
    end
    function addCallback(o,dep)
        o.deps.(dep.label) = dep;
        o.fig.bringToFront;
    end
end
methods (Static)
    function update(fig,evt)
        t_total_stamp = tic;
        o = fig.UserData;
        switch evt.EventName
        case 'MovingROI'
            detail_level = 0.25;
            time_range = 5:8;
            rate = 1/(1+o.move_timing_num);
            o.move_timing_num = 0.75*o.move_timing_num + 1;
        case 'ROIMoved'
            detail_level = 1;
            time_range = 9:12;
            rate = 1/(1+o.stop_timing_num);
            o.stop_timing_num = 0.75*o.stop_timing_num + 1;
        end
        deps = struct2cell(o.deps);
        for i = 1:length(deps)
            h = deps{i}; h.defined = true;
            b = true;
            for j = 1:length(h.inputs)
                b = b & h.inputs{j}.defined;
            end            
            if ~b; continue; end
            ts = tic;                    % (((
            h.update(detail_level);
            h.last_total_time = toc(ts); % )))
            if(~h.defined); continue; end
            h.runtimes(time_range) = h.runtimes(time_range)*(1-rate) + h.runtimes(1:4)*rate;
        end
        t_total_time = toc(t_total_stamp);
        switch evt.EventName
        case 'MovingROI'
            o.move_total_time = o.move_total_time*(1-rate) + t_total_time*rate;
        case 'ROIMoved'
            o.stop_total_time = o.stop_total_time*(1-rate) + t_total_time*rate;
        end
    end
end
end