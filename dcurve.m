classdef dcurve < dependent
methods
    function o = dcurve(parent,label,labels,callback,args)
        o = o@dependent(parent,label,labels,callback);
        ret = o.call;
        o.fig = line(o.parent.ax,ret{1},ret{2},args{:});
    end
    function v = value(o)
        %v = struct('XData',o.fig.XData,'YData',o.fig.YData);
        v = [o.fig.XData(:) o.fig.YData(:)];
    end
    function updatePlot(o,xdata,ydata)
        o.fig.XData = xdata;
        o.fig.YData = ydata;
    end
end
methods (Static)
    function [outs] = parseOutputs(args)
        if length(args) == 1
            xy = args{1};
            if size(xy,2) == 2
                outs{1} = xy(:,1);
                outs{2} = xy(:,2);
            elseif size(xy,1) == 2
                outs{1} = xy(1,:);
                outs{2} = xy(2,:);
            end
        elseif length(args) == 2
            outs{1} = args{1};
            outs{2} = args{2};
        else
            error 'Callback has too many outputs.'
        end
    end
end
end