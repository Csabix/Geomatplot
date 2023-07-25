classdef dimage < dependent
properties
    c0
    c1
end
methods
    function o = dimage(parent,label,labels,callback,c0,c1,args)
        o = o@dependent(parent,label,labels,callback);
        o.c0 = c0;      o.c1 = c1;
        o.fig = imagesc('XData',[0 1],'YData',[0 1],'CData',0,args{:});
        o.fig.UserData = o;
        uistack(o.fig,"bottom");
        if isa(o.c0,'point_base')
            o.addCallbacks({c0});
        end
        if isa(o.c1,'point_base')
            o.addCallbacks({c1});
        end
        o.update(1);
    end

    function v = value(o)
        v = [o.getRange(1); o.getRange(2)]';
    end

    function update(o,detail_level)
        [x,y] = o.getMeshgrid(256*detail_level);
        o.call(x,y);
    end

    function updatePlot(o,C)
        o.fig.CData = C;
        o.fig.XData = o.getRange(1);
        o.fig.YData = o.getRange(2);
    end
    
end
methods (Access=private)
    function r = getRange(o,dim)
        if isa(o.c0,'point_base')
            c0 = o.c0.value;
        else
            c0 = o.c0;
        end
        if isa(o.c1,'point_base')
            c1 = o.c1.value;
        else
            c1 = o.c1;
        end
        r = [c0(dim) c1(dim)];
        if r(1)>r(2); r = r([2 1]); end
    end
    function [x,y] = getMeshgrid(o,res)
        xr = o.getRange(1); yr = o.getRange(2);
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