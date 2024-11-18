%% Triangle
clf; disp Triangle

A = Point([0.0 0.0]);     % draggable point, automatically labelled A
B = Point([1.0 0.0]);     % automatic labels are applied if no label is given
C = Point([0.6 .55]);
ab = Segment(A,B,'b',2);  % a blue segment from A and B
bc = Segment(B,C,'b',2);  %         with LineWidth of 2
cd = Segment(C,A,'b',2);

Segment(A,Midpoint(B,C),'--')
Segment(B,Midpoint(C,A),'--')
Segment(C,Midpoint(A,B),'--')
S=Midpoint('S',A,B,C,'k',7);        % Barycenter of the triangle labelled S

PerpendicularBisector(A,B,':')
PerpendicularBisector(B,C,':')
PerpendicularBisector(C,A,':')
[~,K] = Circle(A,B,C,'m--');        % Magenta dashed circumcircle of the triangle
Text(K,"K") % add text at position

la = AngleBisector(A,B,C,':');
lb = AngleBisector(B,C,A,':');
lc = AngleBisector(C,A,B,':');
Circle(Intersect('O',la,lb),ab,'c');% (inscribed) circle touching segment AB

ma = PerpendicularLine(A,B,C,':');
mb = PerpendicularLine(B,C,A,':');
mc = PerpendicularLine(C,A,B,':');
M = Intersect('M',ma,mb);
Segment(M,K,'r')                    % Euler line