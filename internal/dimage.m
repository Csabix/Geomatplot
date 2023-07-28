classdef dimage < dependent
properties
    corner0
    corner1
end
methods
    function o = dimage(parent,label,inputs,callback,c0,c1,args)
        fig = imagesc('XData',[0 1],'YData',[0 1],'CData',0,args{:});
        uistack(fig,"bottom");
        o = o@dependent(parent,label,fig,inputs,[]);
        o.corner0 = c0;      o.corner1 = c1;
        o.callback = callback;
        if isa(o.corner0,'point_base')
            inputs = [inputs {c0}];
        end
        if isa(o.corner1,'point_base')
            inputs = [inputs {c1}];
        end
        o.addCallbacks(inputs);
        o.update;
        if ~isempty(o.exception); rethrow(o.exception); end
    end

    function v = value(o)
        [x,y] = o.getRanges;
        v = [x;y]';
    end

    function update(o,detail_level)
        if nargin < 2; detail_level = 1; end
        [x,y] = o.getMeshgrid(256*detail_level);
        o.call(x,y);
    end

    function updatePlot(o,C)
        o.fig.CData = C;
        [o.fig.XData,o.fig.YData] = o.getRanges;
    end
    
end
methods (Access=private)
    
    function [xrange,yrange] = getRanges(o)
        if isa(o.corner0,'point_base')
            c0 = o.corner0.value;
        else
            c0 = o.corner0;
        end
        if isa(o.corner1,'point_base')
            c1 = o.corner1.value;
        else
            c1 = o.corner1;
        end
        xrange = [c0(1) c1(1)];
        if xrange(1)>xrange(2); xrange = xrange([2 1]); end
        yrange = [c0(2) c1(2)];
        if yrange(1)>yrange(2); yrange = yrange([2 1]); end
    end
    
    function [x,y] = getMeshgrid(o,res)
        [xr,yr] = o.getRanges;
        xl = xr(2) - xr(1); yl = yr(2) - yr(1);
        x = linspace(xr(1),xr(2),res*xl/(xl+yl));
        y = linspace(yr(1),yr(2),res*yl/(xl+yl));
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