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

CD = CustomValue(A,r1,B,r2,C,r3,@apolloniuses);
for i = 1:8
    O = Point("O"+string(i),CD,@(cd) cd.center(i,:));
    r = Scalar("r"+string(i),CD,@(cd) cd.radius(i));
    Circle("acirc"+string(i),O,r,'m--',1);
end

function o = apolloniuses(o1,r1,o2,r2,o3,r3)
    signs = [+1 +1 +1; +1 +1 -1; +1 -1 +1; -1 +1 +1; +1 -1 -1; -1 +1 -1; -1 -1 +1; -1 -1 -1];
    o = struct('center',[],'radius',[]);
    for i = 1:8
        p = apolloniusf(o1,r1*signs(i,1),o2,r2*signs(i,2),o3,r3*signs(i,3));
        o.center = [o.center; p.center];
        o.radius = [o.radius; p.radius];
    end
end

function o = apolloniusf(o1,r1,o2,r2,o3,r3)
    x1 = o1(1);     y1 = o1(2);
    x2 = o2(1);     y2 = o2(2);
    x3 = o3(1);     y3 = o3(2);
    a2 = 2*(x2-x1); b2 = 2*(y2-y1); c2 = 2*(r2-r1);
    d2 = (x2*x2+y2*y2-r2*r2)-(x1*x1+y1*y1-r1*r1);
    a3 = 2*(x3-x1); b3 = 2*(y3-y1); c3 = 2*(r3-r1);
    d3 = (x3*x3+y3*y3-r3*r3)-(x1*x1+y1*y1-r1*r1);
    mul = 1/(a2*b3-a3*b2);
    xc = ( +b3*d2-b2*d3)*mul;    xr = (-b3*c2+b2*c3)*mul;
    yc = ( -a3*d2+a2*d3)*mul;    yr = (+a3*c2-a2*c3)*mul;
    A = xr*xr + yr*yr - 1;                                         % r^2
    B = 2*(xc*xr + yc*yr - xr*x1 - yr*y1 - r1);                    % r^1
    C = xc*xc + yc*yc - 2*xc*x1 - 2*yc*y1 + x1*x1 + y1*y1 - r1*r1; % r^0
    r = roots([A B C]); %quadratic
    o = struct('center',[],'radius',[]);
    r = r(isreal(r) & r>0);
    o.center = [o.center; xc + xr*r, yc + yr*r];
    o.radius = [o.radius; r];
end