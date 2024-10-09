classdef dcircle < dcurve
properties
    center
    radius
    gen_dist
end
methods
    function o = dcircle(parent,label,center,radius,gen_dist,args)
        callback = @(t,c,r) c.value+r.value*[cos(2*pi*t) sin(2*pi*t)];
        o = o@dcurve(parent,label,{center,radius},callback,args);
        o.radius = radius;
        o.center = center;
        o.gen_dist = gen_dist;
    end
    function s = string(o)
        s = "c=" + string(o.center,2) + " r=" + string(o.radius,2);
    end
end
end