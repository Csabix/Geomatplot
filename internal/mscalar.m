classdef mscalar < movable
%   mscalar módosítható értékő skalár változó update-et generál amikor
%   módosul. TODO osztályszerkezet
%
% Korábbi beszélgetés:
% Lehet egy danimation ami egy scalar-t változtat amitől az függ amit
% akarsz. Ez az objektum viszont változtatja a dscalart időközönként stb.
% Sőt, kiirhatja gifbe vagy png-kbe az outputot, ekkor teljes rajzolást
% hívva és rajzolási sebességet (dt-t) nem figyelmbe véve.
%
% Amiért nem implementáltam még, az az, hogy a Geogebra ezt kicsit másképp
% csinálja: minden skalár gyakorlatilag egy csúszka, és bármelyikhez lehet
% animációt beállítani. Kicsit káosz, kérdés hogy jó ötlet-e.
%
% Szerintem több danimation mehet egymástól függetlenül, csak a helyes
% időtöltést lesz nehéz megoldani.
%
% Másik hasznos funkció az lenne, ha egy animációval már lepakolt
% mozgatható objektumot lehetne mozgatni, pl életre kelteni gifek
% formájában a github főoldalát. Akár fel is lehetne venni egy mozgást.

properties
    val (1,1) double
end

methods
    function o = mscalar(parent,label)
        o@movable(parent,label,[]);
    end

    function v = value(o)
        v = o.val;
    end

    function set(o,v)
        o.val = v;
        moveable.update(o.fig,stuct('EventName','MovingROI')); % todo new type
    end
end
end

