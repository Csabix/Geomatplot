clf; % C:\Users\csabi\OneDrive\Dokumentumok\MATLAB\2023\Geomatplot\examples\cyclographs.m
A  = Point('A' ,[0.23741 0.44244],[0 0 1],8);
Ap = Point('Ap',[0.38279 0.65187],[0 0 1],8);
B  = Point('B' ,[0.75425 0.35971],[0 0 1],8);
Bp = Point('Bp',[0.89568 0.48681],[0 0 1],8);
P  = Point('P' ,[0.20983 0.06715],[0 0 1],8);
Q  = Point('Q' ,[0.95084 0.08393],[0 0 1],8);
[circ1,~,r1] = Circle('circ1',A,Ap,'g-',2);
[circ2,~,r2] = Circle('circ2',B,Bp,'g-',2);
line1 = Line('line1',P,Q,'g-',2);
line2 = Line('line2',A,B,'k-',1);
perpln1 = PerpendicularLine('perpln1',A,B,'k:',1);
perpln2 = PerpendicularLine('perpln2',B,A,'k:',1);
G = Intersect('G',circ1,perpln1);
H = Intersect('H',circ2,perpln2);
line3 = Line('line3',G,H,'k--',1);
I = Intersect('I',line3,line2,'r');
parln1 = ParallelLine('parln1',P,Q,r1,'k--');
X  = Point('X' ,[0.30084 0.80393],[0 0 1],8);
line4 = Line('line4',I,X,'k--');
parln2 = ParallelLine('parln2',A,I,X,'k--');
G = Intersect(line4,line1);
D = Intersect(parln1,parln2);
line5 = Line(D,G,'m');
E = Intersect(line5,line2);
Circle(E,line1,'r')

%%
clf;
A  = Point('A' ,[0.23741 0.44244],[0 0 1],8);
Ap = Point('Ap',[0.08279 0.45187],[0 0 1],8);
B  = Point('B' ,[0.75425 0.35971],[0 0 1],8);
Bp = Point('Bp',[0.89568 0.48681],[0 0 1],8);
C  = Point('C' ,[0.43741 0.64244],[0 0 1],8);
Cp = Point('Cp',[0.48279 0.70187],[0 0 1],8);
[circ1,~,r1] = Circle('circ1',A,Ap,'g-',2);
[circ2,~,r2] = Circle('circ2',B,Bp,'g-',2);
[circ3,~,r3] = Circle('circ3',C,Cp,'g-',2);
P = Point('p',A,r1,B,r2,C,r3,@apollonius);

function o = apollonius(o1,r1,o2,r2,o3,r3)
    x1 = o1(1); y1 = o1(2);
    x2 = o2(1); y2 = o2(2);
    x3 = o3(1); y3 = o3(2);
    a2 = 2*(x1-x2);
    b2 = 2*(y1-y2);
    c2 = 2*(r1+r2);
    d2 = (x1*x1+y1*y1-r1*r1)-(x2*x2+y2*y2-r2*r2);
    a3 = 2*(x1-x3);
    b3 = 2*(y1-y3);
    c3 = 2*(r1+r3);
    d3 = (x1*x1+y1*y1-r1*r1)-(x3*x3+y3*y3-r3*r3);
    mul = 1/(a2*b3-b2*a3);
    xc = (b3*d2-b2*d3)*mul;
    yc = (a3*d2-a2*d3)*mul;
    xr = (b2*c3-b3*c2)*mul;
    yr = (a3*c2-a2*c3)*mul;
    A = xr*xr + yr*yr - 1;  %r^2
    B = 2*(xr*xc + yr*yc - r1 - x1*xr - y1*yr); %r
    C = xc*xc+yc*yc + 2*x1*xc + 2*y1*yc + x1*x1+y1*y1-r1*r1;%const
    sols = roots([A B C]);
    r = sols(2);
    x = xc + xr*r;
    y = yc + yr*r;
    o=[x y];
end