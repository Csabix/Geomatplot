classdef dimage < dependent
properties
    Resolution (1,1) double = 1024;
    corner0
    corner1
end
methods
    function o = dimage(parent,label,inputs,callback,c0,c1,args,resolution)
        args = namedargs2cell(args);
        fig = imagesc('XData',[0 1],'YData',[0 1],'CData',0,args{:});
        uistack(fig,'bottom');
        o = o@dependent(parent,label,fig,inputs,[]);
        if nargin >= 8; o.Resolution = resolution; end
        o.corner0 = c0; o.corner1 = c1;
        if isa(o.corner0,'point_base'); inputs = [inputs {c0}]; end
        if isa(o.corner1,'point_base'); inputs = [inputs {c1}]; end
        o.setUpdateCallback(callback,inputs);
    end

    function v = value(o)
        [x,y] = o.getRanges;
        v = [x;y]';
    end

    function update(o,detail_level)
        if nargin < 2; detail_level = 1; end
        [xr,yr,xn,yn] = o.getRanges(detail_level);
        o.call(xr,xn,yr,yn);
    end

    function updatePlot(o,C)
        if isgpuarray(C)
        o.fig.CData = gather(C);
        else
        o.fig.CData = C;
        end
        [o.fig.XData,o.fig.YData] = o.getRanges;
    end
    
end
methods (Access=private)
    
    function [xrange,yrange,xn,yn] = getRanges(o,detail_level)
        if nargin < 2; detail_level = 1; end
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
        if nargout > 2
            xl = diff(xrange);  yl = diff(yrange);
            xn = round(2*detail_level*o.Resolution*xl/(xl+yl));
            yn = round(2*detail_level*o.Resolution*yl/(xl+yl));
        end
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