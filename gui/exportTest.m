clf; % gui/exportTest.m
A = Point('A',[0.30989 0.42219],[0 0 1],8);
B = Point('B',[0.327272727272727 0.636898395721925],[0 0 1],8);
C = Point('C',[0.53369 0.34278],[0 0 1],8);
D = Point('D',[0.658823529411765 0.575935828877005],[0 0 1],8);
FFF = Midpoint('FFF',B,D);
circ1 = Circle('circ1',FFF,C,'-',1);
circ2 = Circle('circ2',B,D,'-',1);
[circ3,center1] = Circle('circ3',A,B,FFF,'-',1);
