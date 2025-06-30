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

Image(b0,b1,b2,@dist2bezier,c1,c2,Device='CPU',CallbackType='vectorize');