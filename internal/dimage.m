classdef dimage < dependent
properties
    xrange
    yrange
end
methods
    function o = dimage(parent,label,labels,callback,xr,yr,args)
        o = o@dependent(parent,label,labels,callback);
        o.xrange = xr;      o.yrange = yr;
        [x,y] = o.getMeshgrid(256);
        ret = o.call(x,y);
        o.fig = imagesc('XData',xr,'YData',yr,'CData',ret{1},args{:});
        o.fig.UserData = o;
        uistack(o.fig,"bottom");
    end
    function v = value(o)
        v = o.fig.CData;
    end
    function update(o,detail_level)
        [x,y] = o.getMeshgrid(256*detail_level);
        ret = o.call(x,y);
        o.updatePlot(ret{:});
    end
    function updatePlot(o,C)
        o.fig.CData = C;
    end
end
methods (Access=private)
    function [x,y] = getMeshgrid(o,res)
        xl = o.xrange(2) - o.xrange(1); yl = o.yrange(2) - o.yrange(1);
        x = linspace(o.xrange(1),o.xrange(2),res*xl/(xl+yl));
        y = linspace(o.yrange(1),o.yrange(2),res*yl/(xl+yl));
        [x,y] = meshgrid(x,y);
    end
end
methods (Static)
    function outs = parseOutputs(args)
        if length(args) == 1
            outs{1} = args{1};
        elseif length(args) == 3
            outs{1} = cat(3,args{1},args{2},args{3}); %rgb
        else
            error 'Callback has the wrong number of outputs.'
        end
    end
end
end