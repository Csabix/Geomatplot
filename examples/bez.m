
%% Focal-directrix parabola to quadratic Bézier representation
%clf; tiledlayout(1,2,'Padding','tight'); nexttile

p1 = Point('p1',[0 0.2]);
p2 = Point('p2',[1 0.2]);
f  = Point('f',[.6 .8]);

Segment(p1,p2,'b-')

e0 = PerpendicularBisector(f,p1,':');
e1 = PerpendicularBisector(f,p2,':');
b0 = Intersect('b0',PerpendicularLine({p1,p2},':'),e0,'r');
b2 = Intersect('b2',PerpendicularLine({p2,p1},':'),e1,'r');
b1 = Intersect('b1',e0,e1,'r');

fun = @(t,b0,b1,b2)  b0.*(1-t).^2 + 2*b1.*t.*(1-t) + b2.*t.^2;
Curve(p1,p2,f ,@parabola,'b--')
Curve(b0,b1,b2,fun      ,'r:')

%% Quadratic Bézier to focal-directrix parabola representation
b0 = b0.value; b1 = b1.value; b2 = b2.value;
%nexttile; cla;

b0 = Point('b0',b0,'r');
b1 = Point('b1',b1,'r');
b2 = Point('b2',b2,'r');

a = (b0-b1)+(b2-b1);
%Vector(b1,b1+a,'--')
fb0 = Mirror(b0 + a, PerpendicularLine(b0,b1,':'), 'k',5,'LabelVisible','off');
fb2 = Mirror(b2 + a, PerpendicularLine(b2,b1,':'), 'k',5,'LabelVisible','off');

f = Intersect({'F'}, Line(b0,fb0,':'), Line(b2,fb2,':'),'b');
p1 = Mirror('p1',f,b0,b1,'b');
p2 = Mirror('p2',f,b1,b2,'b');

Segment(p1,p2,'b-')
Curve(p1,p2,f ,@parabola,'b--')
Curve(b0,b1,b2,fun      ,'r:')

%% parabola
function pt = parabola(t,p1,p2,f) % Eval parabola with directrix p1p2 and focus f at t column vector
    arguments
        t  (:,1) double
        p1 (1,2) double; p2 (1,2) double; f  (1,2) double
    end
    n = (p2-p1)*[0 1;-1 0];
    lin = p1.*(1-t)+p2.*t;
    pt =  lin + 0.5/dot(f-p1,n,2)*dot(lin-f,lin-f,2).*n;
end