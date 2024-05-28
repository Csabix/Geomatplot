clf; % gui/exportTest.m
A = Point('A',[0.26417 0.57861],[0 0 1],8);
B = Point('B',[0.43743 0.69866],[0 0 1],8);
C = Point('C',[0.596791443850268 0.371657754010695],[0 0 1],8);
E = Point('E',[0.64679 0.66524],[0 0 1],8);
F = Point('F',[0.7262 0.71096],[0 0 1],8);
circ1 = Circle('circ1',A,B,'k-',1);
perpln1 = PerpendicularLine('perpln1',C,circ1,'k-',1);
circ2 = Circle('circ2',E,F,'k-',1);
G = ClosestPoint('G',C,circ2,[0 1 0],8);
H = Midpoint('H',B,C,[1 0 0],6);
