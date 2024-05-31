classdef mpoint < moveable & point_base
methods
    function o = mpoint(parent,label,args)
        args = namedargs2cell(args);
        h = drawPoint(args{:});
        o = o@moveable(parent,label,h,@mpoint.update);
        o.labelfig.Position = o.fig.Position;
        o.labelfig.Visible = true;
    end
    function v = value(o)
        v = o.fig.Position;
    end
end

methods(Static)
function update(fig,evt)
    moveable.update(fig,evt);
    labelfig = fig.UserData.labelfig;
    labelfig.Position = fig.Position;
end

end

end