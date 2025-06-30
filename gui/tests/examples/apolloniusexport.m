clf; 
A = Point('A',[0.23741 0.44244],[0 0 1],8);
Ap = Point('Ap',[0.08279 0.45187],[0 0 1],8);
B = Point('B',[0.75425 0.35971],[0 0 1],8);
Bp = Point('Bp',[0.89568 0.48681],[0 0 1],8);
C = Point('C',[0.43741 0.64244],[0 0 1],8);
Cp = Point('Cp',[0.48279 0.70187],[0 0 1],8);
[circ1,~,dist1] = Circle('circ1',A,Ap,'-',2,'Color',[0 1 0]);
[circ2,~,dist2] = Circle('circ2',B,Bp,'-',2,'Color',[0 1 0]);
[circ3,~,dist3] = Circle('circ3',C,Cp,'-',2,'Color',[0 1 0]);
custom1 = CustomValue('custom1',A,dist1,B,dist2,C,dist3,@apolloniuses);
i = 1;
O1 = Point('O1',custom1,@(cd)cd.center(i,:),[0 0 0],6);
i = 1;
r1 = Scalar('r1',custom1,@(cd)cd.radius(i));
[acirc1,~,~] = Circle('acirc1',O1,r1,'--',1,'Color',[1 0 1]);
i = 2;
O2 = Point('O2',custom1,@(cd)cd.center(i,:),[0 0 0],6);
i = 2;
r2 = Scalar('r2',custom1,@(cd)cd.radius(i));
[acirc2,~,~] = Circle('acirc2',O2,r2,'--',1,'Color',[1 0 1]);
i = 3;
O3 = Point('O3',custom1,@(cd)cd.center(i,:),[0 0 0],6);
i = 3;
r3 = Scalar('r3',custom1,@(cd)cd.radius(i));
[acirc3,~,~] = Circle('acirc3',O3,r3,'--',1,'Color',[1 0 1]);
i = 4;
O4 = Point('O4',custom1,@(cd)cd.center(i,:),[0 0 0],6);
i = 4;
r4 = Scalar('r4',custom1,@(cd)cd.radius(i));
[acirc4,~,~] = Circle('acirc4',O4,r4,'--',1,'Color',[1 0 1]);
i = 5;
O5 = Point('O5',custom1,@(cd)cd.center(i,:),[0 0 0],6);
i = 5;
r5 = Scalar('r5',custom1,@(cd)cd.radius(i));
[acirc5,~,~] = Circle('acirc5',O5,r5,'--',1,'Color',[1 0 1]);
i = 6;
O6 = Point('O6',custom1,@(cd)cd.center(i,:),[0 0 0],6);
i = 6;
r6 = Scalar('r6',custom1,@(cd)cd.radius(i));
[acirc6,~,~] = Circle('acirc6',O6,r6,'--',1,'Color',[1 0 1]);
i = 7;
O7 = Point('O7',custom1,@(cd)cd.center(i,:),[0 0 0],6);
i = 7;
r7 = Scalar('r7',custom1,@(cd)cd.radius(i));
[acirc7,~,~] = Circle('acirc7',O7,r7,'--',1,'Color',[1 0 1]);
i = 8;
O8 = Point('O8',custom1,@(cd)cd.center(i,:),[0 0 0],6);
i = 8;
r8 = Scalar('r8',custom1,@(cd)cd.radius(i));
[acirc8,~,~] = Circle('acirc8',O8,r8,'--',1,'Color',[1 0 1]);

xlim([0.00000 1.00000]); ylim([0.00000 1.00000]);

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
