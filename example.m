% Examples

%% Geogebra like triangle
clf; g = Geomatplot; ylim([-0.4 0.6])
A = Point([0  0]); % draggable point, automatically labelled A
B = Point([1  0]); % automatic labels are applied if no label is given
C = Point([.7 .5]);
%CircularArc({A,B,C});
Segment({A,B},'b'); % a blue segment from A and B
Segment({B,C},'b');
Segment({C,A},'b');
Midpoint('S',{A,B,C}); % Barycenter of triangle labelled S
[~,~,r] = Circle({A,B,C},'m--'); % Magenta dashed circumcircle of the triangle
PerpendicularBisector({A,B},':');
PerpendicularBisector({B,C},':');
PerpendicularBisector({C,A},':');
AngleBisector({A,B,C},':');
AngleBisector({B,C,A},':');
AngleBisector({C,A,B},':');

%% Image
clf; g = Geomatplot;
b0 = Point('b0',[0.1 0.2],'r'); % draggable control points
b1 = Point('b1',[0.7 0.9],'r'); % with given labels
b2 = Point('b2',[0.9 0.2],'r');
c1 = Point('c1',[-.5 0],'k','MarkerSize',5); % adjustable corner
c2 = Point('c2',[1.5 1],'k','MarkerSize',5); %   for the image
% parametric callback with t in [0,1] and dependent variables:
bt = @(t,b0,b1,b2)  b0.*(1-t).^2 + 2*b1.*t.*(1-t) + b2.*t.^2;
b = Curve(bt,{b0,b1,b2},'r'); % A red quadratic Bézier curve
Image(@dist2bezier,{b0,b1,b2},c1,c2); colorbar;
% where 'dist2bezier' is a (x,y,b0,b1,b2) -> real function
P = Point('P',[0 0],'y');
Circle({P,b},'y');

%% Test
clf; g = Geomatplot;
A = Point([0 1]); 
B = Point([1 0]); 
C = Point([0 0]); 
D = Point([.6 .6]);
a = Circle({A,B});
b = Circle({C,D});
[EF,gg] = Intersect(2,{a,b});

%% Polygon
clf; g = Geomatplot;
f = Polygon([-1 0;1 0;1 1;0.7 0.7;0.3 0.5;0 0.9;-0.5 0.3;-1 0.3],'g');
p0 = Point('p0',[-1,1]);
Point('v0',[-0.9,0.9]);
l = Line({'p0','v0'},'k');
r = Ray({'p0','v0'},'r');
p = p0;
for i = 1:15
    c = Circle({p,f});
    p = Intersect({l,c});
end

%%
clf; g = Geomatplot;
A = Point([0,0]);
B = Point([1,1]);
c = Circle('c',{A,B});
P = Point('p',[.5 .5]);
Circle({P,c});

%% dist2bezier

function v = dist2bezier(x,y,b0,b1,b2)
    function v = gdot(a,b)
        v = dot(a,b,2);
    end
    function v = gdot2(a)
        v = dot(a,a,2);
    end
    v = x*0;
    for i=1:size(x,1); for j=1:size(x,2) %slow
        p = [x(i,j) y(i,j)];
        pb0 = p-b0; pb1 = p-b1; pb2 = p-b2;
        a = gdot2(pb0-2*pb1+pb2);
        b = 3*gdot(pb1-pb0, pb0-2*pb1+pb2);
        c = 3*gdot2(pb0)  - 6*gdot(pb0,pb1) ...
          + gdot(pb2,pb0) + 2*gdot2(pb1);
        d = gdot(pb0,pb1-pb0);
        t = roots([a,b,c,d]);
        t = real(t(abs(imag(t))<1e-10));
        t = [t(0<t & t<1); 0; 1];
        if isempty(t); t = 0; end
        d = gdot2(pb0.*(1-t).^2 + 2*pb1.*t.*(1-t) + pb2.*t.^2);
        v(i,j) = min(sqrt(d));
    end; end
end


