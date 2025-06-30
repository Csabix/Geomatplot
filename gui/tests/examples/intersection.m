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