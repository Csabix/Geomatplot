clf; 
A = Point('A',[0.41702 0.72032],[0 0 1],8);
B = Point('B',[0.00011 0.30233],[0 0 1],8);
C = Point('C',[0.14676 0.09234],[0 0 1],8);
D = Point('D',[0.18626 0.34556],[0 0 1],8);
E = Point('E',[0.39677 0.53882],[0 0 1],8);
F = Point('F',[0.41919 0.68522],[0 0 1],8);
G = Point('G',[0.20445 0.87812],[0 0 1],8);
H = Point('H',[0.02739 0.67047],[0 0 1],8);
I = Point('I',[0.41730 0.55869],[0 0 1],8);
J = Point('J',[0.14039 0.19810],[0 0 1],8);
K = Point('K',[0.80074 0.96826],[0 0 1],8);
L = Point('L',[0.31342 0.69232],[0 0 1],8);
M = Point('M',[0.87639 0.89461],[0 0 1],8);
N = Point('N',[0.08504 0.03905],[0 0 1],8);
O = Point('O',[0.16983 0.87814],[0 0 1],8);
P = Point('P',[0.09835 0.42111],[0 0 1],8);
Q = Point('Q',[0.95789 0.53317],[0 0 1],8);
R = Point('R',[0.69188 0.31552],[0 0 1],8);
S = Point('S',[0.68650 0.83463],[0 0 1],8);
T = Point('T',[0.01829 0.75014],[0 0 1],8);
U = Point('U',[0.98886 0.74817],[0 0 1],8);
V = Point('V',[0.28044 0.78928],[0 0 1],8);
W = Point('W',[0.10323 0.44789],[0 0 1],8);
X = Point('X',[0.90860 0.29361],[0 0 1],8);
Y = Point('Y',[0.28778 0.13003],[0 0 1],8);
Z = Point('Z',[0.01937 0.67884],[0 0 1],8);
A1 = Point('A1',[0.21163 0.26555],[0 0 1],8);
B1 = Point('B1',[0.49157 0.05336],[0 0 1],8);
C1 = Point('C1',[0.57412 0.14673],[0 0 1],8);
D1 = Point('D1',[0.58931 0.69976],[0 0 1],8);
seq1 = PointSequence(A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z,A1,B1,C1,D1,[0 0 0],2);
[scal1,sliderx1,txt1] = drawSliderX('sliderx1',[0.00000 1.00000],[1.00000 1.00000],1.00000,0.00000);
custom1 = CustomValue('custom1',seq1,scal1,@alphaShape);
segseq1 = SegmentSequence('segseq1',custom1,@(as)as.Points(boundaryFacets(as)',:),0,'-',1,'Color',[0 1 1]);
GeomMed = Point('GeomMed',seq1,@weiszfeld_algorithm);

xlim([-0.19770 1.26640]); ylim([-0.24024 1.22386]);

function gm = weiszfeld_algorithm(points)
    tol = 1e-6;
    gm = mean(points, 1);
    for iter = 1:100
        distances = sqrt(sum((points - gm).^2, 2));
        if any(distances < tol); break; end
        weights = 1 ./ distances;
        gm_new = sum(points .* weights, 1) / sum(weights);
        if norm(gm_new - gm) < tol
            gm = gm_new;
            break;
        end
        gm = gm_new;
    end
end
