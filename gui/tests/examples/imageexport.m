clf; 
b0 = Point('b0',[0.10000 0.20000],[1 0 0],8);
b1 = Point('b1',[0.70000 0.90000],[1 0 0],8);
b2 = Point('b2',[0.90000 0.20000],[1 0 0],8);
P = Point('P',[0.50000 0.40000],[1 1 0],8);
c1 = Point('c1',[-0.25000 0.00000],[0 0 1],5);
c2 = Point('c2',[1.25000 1.00000],[0 0 1],5);
curve1 = Curve('curve1',b0,b1,b2,@(t,b0,b1,b2)b0.*(1-t).^2+2*b1.*t.*(1-t)+b2.*t.^2,'-',2,'Color',[1 0 0]);
scal1 = Scalar('scal1',P,b0,b1,b2,@(P,A,B,C)dist2bezier(complex(P(1),P(2)),complex(A(1),A(2)),complex(B(1),B(2)),complex(C(1),C(2))));
[circ1,~,~] = Circle('circ1',P,scal1,'-',1,'Color',[1 1 0]);
txt1 = Text(P,scal1);
image1 = Image('image1',b0,b1,b2,@dist2bezier,c1,c2,Resolution=1024,CallbackType='vectorize',Device='CPU',Representation='complex');

xlim([0.00000 1.00000]); ylim([0.00000 1.00000]);
