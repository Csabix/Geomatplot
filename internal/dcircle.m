classdef dcircle < dcurve
properties
    center
    radius
end
methods
    function o = dcircle(parent,label,center,radius,args)
        callback = @(t,c,r) c.value+r.value*[cos(2*pi*t) sin(2*pi*t)];
        o = o@dcurve(parent,label,{center,radius},callback,args);
        o.radius = radius;
        o.center = center;
        radius.labelfig.Visible = false;
        %o.labelfig.Position = o.center.value;
        o.labelfig.Offset = [0,40];
    end

    function update(o,~)
        update@dcurve(o);
        %if ~isempty(o.center)
        %    o.labelfig.Position = o.center.value;
        %end
    end

    function s = string(o)
        s = "c=" + string(o.center,2) + " r=" + string(o.radius,2);
    end
end
end