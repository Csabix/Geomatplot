clf; % gui/exportTest.m
A = Point('A',[0.22326 0.49893],[0 0 1],8);
B = Point('B',[0.33877 0.60989],[0 0 1],8);
C = Point('C',[0.39144385026738 0.316042780748663],[0 0 1],8);
D = Point('D',[0.658823529411765 0.42192513368984],[0 0 1],8);
E = Point('E',[0.54813 0.50642],[0 0 1],8);
F = Point('F',[0.62995 0.10936],[0 0 1],8);
G = Point('G',[0.6516 0.17674],[0 0 1],8);
H = Point('H',[-0.21709 0.00111],[0 0 1] ...
    ,8);
I = Point('I',[-0.27094 0.13959],[0 0 1],8);
J = Point('J',[-0.39788 0.29346],[0 0 1],8);
K = Point('K',[-0.09399 0.37809],[0 0 1],8);
L = Point('L',[0.586361711898613 -0.439389616285695],[0 0 1],8);
M = Point('M',[0.0852038604639688 -0.750107484175174],[0 0 1],8);
N = Point('N',[0.400933306867794 -0.647370124631072],[0 0 1],8);
O = Point('O',[0.423485410182353 -0.998180620635323],[0 0 1],8);
P = Point('P',[0.74924 -1.20052],[0 0 1],8);
Q = Point('Q',[0.92965 -1.32456],[0 0 1],8);
R = Point('R',[1.07624 -0.91298],[0 0 1],8);
S = Point('S',[1.23411 -1.08212],[0 0 1],8);
carc1 = CircularArc('carc1',A,B,C,'k-',1);
D1 = Mirror('D1',D,E,[0 1 0],7);
C1 = Mirror('C1',C,E,D,[0 0 0],6);
circ1 = Circle('circ1',F,G,'k-',1);
circ11 = Mirror('circ11',circ1,E,'g-.',2);
circ2 = Circle('circ2',I,H,'k-',1);
circ21 = Mirror('circ21',circ2,J,K,'b:',2);
curve1 = Curve('curve1',M,N,O,@(t,p0,p1,p2)p0.*(1-t).^2+2*p1.*t.*(1-t)+p2.*t.^2,'k-',1);
curve11 = Mirror('curve11',curve1,L,'g--',1);
seg1 = Segment('seg1',P,Q,'k-',1);
seg11 = Mirror('seg11',seg1,R,S,'b-',1);
