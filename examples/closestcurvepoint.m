disp closestcurvepoint; clf;

b0 = Point('b0',[0.1 0.2],'r'); % draggable control points
b1 = Point('b1',[0.7 0.9],'r'); % with given labels
b2 = Point('b2',[0.9 0.2],'r');

% parametric callback with t in [0,1] and dependent variables:
f = @(t,b0,b1,b2)  b0 + 2*(b1-b0).*t.*(1-t) + (b2-b0).*t.^2;
df = @(t,b0,b1,b2)  2.*(b1-b0).*(1-t) + 2.*(b2-b1).*t;
Curve(b0,b1,b2,f,'r',2);  % A red quadratic Bézier curve

x = Point('x',[.5 .4],'b');

t = drawSliderX('t0',[0 1],[0.1,0.1],0.8);

for i=1:1
    pt = Point(f(t,b0,b1,b2),'c');
    v = Eval(df(t,b0,b1,b2));
    Line(pt,pt+v,'c--');
    %t = ((x-pt)*v)/(v*v);
end