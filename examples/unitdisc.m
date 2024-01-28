clf; disp 'Unit Disc'

o = Point('o',@()[0 0],'m',3,'LabelV','off');
Circle(o,Scalar(@()1),'m'); % unit circle
b = Point('b', [.5 0],'r');

n = 4; rng(0);
ps=cell(n,1); is=ps;
for i = 1:n
    t = rand*2*pi; r = .5*rand+1.1;
    ps{i} = Point([cos(t) sin(t)]*r);
    is{i} = Point(ps{i}.label+"_",ps{i},@(a) a./(a.*a*[1;1]),'c'); % 1/conj(a)
end

% Pseudo-hyperbolic Voronoi diagram
Image(PointSequence(is{:},'Vis','off'),@hypervoronoi,[-1.5 -1.5],[1.5 1.5]);
xlim([-2 2]); ylim([-1.5 1.5])

%% Voronoi diagram
DT = CustomValue(PointSequence(ps{:}),@delaunayTriangulation);
SegmentSequence(DT,@drawVoronoi,0,'m');

%%
function inds = hypervoronoi(z,pts) % z is a N*M matrix
    dist = inf(size(z));
    inds = z*0;
    for i=1:length(pts)
        tmp = abs(  (z-pts(i)) ./ (1-z.*conj(pts(i)))  );
        inds(tmp<dist) = i;
        dist = min(tmp,dist);
    end
end
function xy = drawVoronoi(dt)
    [C,r] = voronoiDiagram(dt); % kinda stupid but returns inf for all unbounded region vertices
    r = cellfun(@(x) [x 1],r,'UniformOutput',false);
    xy = C(horzcat(r{:}),:);
end