classdef dcircle < dcurve
properties
    center
    radius
end
properties (Hidden)
    whattoreturn = 'struct'
end
methods
    function o = dcircle(parent,label,center,radius,linespec,args)
        callback = @(t,c,r) c.value+r.value*[cos(2*pi*t) sin(2*pi*t)];
        o = o@dcurve(parent,label,{center,radius},linespec,callback,args);
        o.radius = radius;
        o.center = center;
    end
%     function v = value(o)
%         switch o.whattoreturn
%             case 'polygon'
%                 v = value@dcurve(o);
%             case 'struct'
%                 v = struct('radius',o.radius.value,'center',o.center.value);
%         end
%     end
end
end