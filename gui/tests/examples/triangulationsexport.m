clf; 
A = Point('A',[0.81472 0.90579],[0 0 1],8);
B = Point('B',[0.12699 0.91338],[0 0 1],8);
C = Point('C',[0.63236 0.09754],[0 0 1],8);
D = Point('D',[0.27850 0.54688],[0 0 1],8);
E = Point('E',[0.95751 0.96489],[0 0 1],8);
F = Point('F',[0.15761 0.97059],[0 0 1],8);
G = Point('G',[0.95717 0.48538],[0 0 1],8);
H = Point('H',[0.80028 0.14189],[0 0 1],8);
I = Point('I',[0.42176 0.91574],[0 0 1],8);
J = Point('J',[0.79221 0.95949],[0 0 1],8);
K = Point('K',[0.65574 0.03571],[0 0 1],8);
L = Point('L',[0.84913 0.93399],[0 0 1],8);
M = Point('M',[0.67874 0.75774],[0 0 1],8);
N = Point('N',[0.74313 0.39223],[0 0 1],8);
O = Point('O',[0.65548 0.17119],[0 0 1],8);
P = Point('P',[0.70605 0.03183],[0 0 1],8);
Q = Point('Q',[0.27692 0.04617],[0 0 1],8);
R = Point('R',[0.09713 0.82346],[0 0 1],8);
S = Point('S',[0.69483 0.31710],[0 0 1],8);
T = Point('T',[0.95022 0.03445],[0 0 1],8);
U = Point('U',[0.43874 0.38156],[0 0 1],8);
V = Point('V',[0.76552 0.79520],[0 0 1],8);
W = Point('W',[0.18687 0.48976],[0 0 1],8);
X = Point('X',[0.44559 0.64631],[0 0 1],8);
Y = Point('Y',[0.70936 0.75469],[0 0 1],8);
Z = Point('Z',[0.27603 0.67970],[0 0 1],8);
A1 = Point('A1',[0.55294 0.45401],[0 0 1],10);
B1 = Point('B1',[0.11900 0.49836],[0 0 1],8);
C1 = Point('C1',[0.95974 0.34039],[0 0 1],8);
D1 = Point('D1',[0.58527 0.22381],[0 0 1],8);
seq1 = PointSequence(A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,A1,B1,C1,D1,[0 0 0],2);
custom1 = CustomValue('custom1',seq1,@delaunayTriangulation);
segseq1 = SegmentSequence('segseq1',custom1,@(dt)dt.Points(edges(dt)',:),0,'-',1,'Color',[0 1 1]);
seq2 = PointSequence(custom1,@(dt)circumcenter(dt),[0 0 0],2);
segseq2 = SegmentSequence('segseq2',custom1,@drawVoronoi,0,'-',1,'Color',[1 0 1]);

xlim([0.00000 1.00000]); ylim([0.00000 1.00000]);

function xy = drawVoronoi(dt)
    [C,r] = voronoiDiagram(dt); % kinda stupid but returns inf for all unbounded region vertices
    r = cellfun(@(x) [x 1],r,'UniformOutput',false);
    xy = C(horzcat(r{:}),:);
end
