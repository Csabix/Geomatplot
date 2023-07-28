classdef dcircle < dcurve
properties
    center
    radius
end
methods
    function o = dcircle(parent,label,center,radius,linespec,args)
        callback = @(t,c,r) c.value+r.value*[cos(2*pi*t) sin(2*pi*t)];
        o = o@dcurve(parent,label,{center,radius},linespec,callback,args);
        o.radius = radius;
        o.center = center;
    end
end
end