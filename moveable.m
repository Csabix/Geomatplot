classdef (Abstract) moveable < drawing % with ROI
methods
    function o=moveable(parent,label)
        o = o@drawing(parent,label);
        o.parent.movs.(label)=o;
    end
    function addCallback(o,callback)
        addlistener(o.fig,'ROIMoved',callback);
        addlistener(o.fig,'MovingROI',callback);
        o.fig.bringToFront;
    end
end
end