clf; % gui/exportTest.m
A = Point('A',[0.11016 0.67968],[0 0 1],8);
B = Point('B',[0.33155 0.67968],[0 0 1],8);
C = Point('C',[0.58716577540107 0.448663101604278],[0 0 1],8);
circ1 = Circle('circ1',A,B,'k-',1);
perpln1 = PerpendicularLine('perpln1',C,circ1,'k-',1);
