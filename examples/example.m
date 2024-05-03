%% Triangle

A = Point([0.0 0.0]);     % draggable point, automatically labelled A
B = Point([1.0 0.0]);     % automatic labels are applied if no label is given
C = Point([0.6 .55]);
ab = Segment(A,B,'b',2);  % a blue segment from A and B
bc = Segment(B,C,'b',2);  %         with LineWidth of 2
cd = Segment(C,A,'b',2);

Segment(A,Midpoint(B,C),'--')
Segment(B,Midpoint(C,A),'--')
Segment(C,Midpoint(A,B),'--')
S=Midpoint('S',A,B,C,'k',7);        % Barycenter of the triangle labelled S

PerpendicularBisector(A,B,':')
PerpendicularBisector(B,C,':')
PerpendicularBisector(C,A,':')
[~,K] = Circle(A,B,C,'m--');        % Magenta dashed circumcircle of the triangle
%Text(K,"K") % add text at position

la = AngleBisector(A,B,C,':');
lb = AngleBisector(B,C,A,':');
lc = AngleBisector(C,A,B,':');
Circle(Intersect('O',la,lb),ab,'c');% (inscribed) circle touching segment AB

ma = PerpendicularLine(A,B,C,':');
mb = PerpendicularLine(B,C,A,':');
mc = PerpendicularLine(C,A,B,':');
M = Intersect('M',ma,mb);
Segment(M,K,'r')                    % Euler line

%ylim([-0.2 0.6]); xlim([-.1 1.1])

%% Polygon Sphere trace
%clf; disp 'Sphere Trace'

% You can move, create, delete vertices of the following polygon:
f = Polygon([-1 0;1 0;1 1;0.7 0.7;0.3 0.5;0 0.9;-0.5 0.3;-1 0.3]);

p0 = Point('p0',[-.8,1.05],'r');    % ray start
q0 = Point('q0',[.5 ,1.05],'r',5);  % ray 'direction'
v0 = Eval((q0-p0)/Distance(p0,q0)); % Operators: point-point=vector, vector/scalar = vector
Ray(p0,v0,'r',1.5)

p = p0; n=15; % Sphere tracing illustration:
for i = 1:n
    d = Distance(p,f); % distance to polygon yields a dependent scalar value
    Circle(p,d,'Color',[i/n 1-i/n 0])
    p = (p + v0*d)';   % vector*scalar=vector, point+vector=point, ' same as Eval
end

%xlim([-1.5 1.3]); ylim([0 1.7])

%% Image
clf; disp 'Curve & Image'
b0 = Point('b0',[0.1 0.2],'r'); % draggable control points
b1 = Point('b1',[0.7 0.9],'r'); % with given labels
b2 = Point('b2',[0.9 0.2],'r');

% parametric callback with t in [0,1] and dependent variables:
fun = @(t,b0,b1,b2)  b0.*(1-t).^2 + 2*b1.*t.*(1-t) + b2.*t.^2;
Curve(b0,b1,b2,fun,'r',2);  % A red quadratic Bézier curve

P = Point('P',[.5 .4],'y'); % dist2bezier takes complex values, need to convert:
dist2bezierReal = @(P,A,B,C) dist2bezier(complex(P(1),P(2)),complex(A(1),A(2)),complex(B(1),B(2)),complex(C(1),C(2)));
d = Scalar(P,b0,b1,b2,dist2bezierReal); % dependent scalar value
Circle(P,d,'y'); Text(P,d)  % Tangent circle to a curve and radius as text

c1 = Point('c1',[-.25 0],'MarkerSize',5); % adjustable corners
c2 = Point('c2',[1.25 1],'MarkerSize',5); % for the image domain

Image(b0,b1,b2,@dist2bezier,c1,c2,Device='GPU',CallbackType='vectorize');
% Where 'dist2bezier' is a (z,b0,b1,b2) -> real function with complex inputs.
% Image supports CPU and GPU execution with or without input vectorization 
% similar to arrayfun. Also accepts real inputs eg.: (x,y,b0,b1,b2) -> real.
% There are limitations and performance considerations, see help for details.

colorbar; xlim([-.25 1.25]); ylim([0 1]) 

%% Intersect

clf; disp Intersect
A = Point([0 1]);
B = Point([1 0]);
C = Point([0 0]);
f = Polygon([-1 0;1 0;1 1;0.7 0.7;0.3 0.5;0 0.9;-0.5 0.3;-1 0.3],'g');
D = Point([.6 .6]);
a = Circle(A,B);
b = Circle(C,D);
Intersect(2,a,b)
Intersect(5,a,f)

D1 = Mirror(D,f);
D2 = Mirror(D,A);
D11 = Mirror(D1,A);