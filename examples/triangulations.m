%% Voronoi and Delaunay triangulation
n = 30; % number of points
pts = cell(1,n); rng(0);
for i = 1:n
    pts{i} = Point(rand(1,2)); % draw draggable points at random
end
pts = PointSequence(pts); % make single pointlist
pts.fig.Visible = false;
% Create a dependent delaunay triangulation structure
DT = CustomValue(pts,@delaunayTriangulation);

% Let us draw the triangulation edges
% the edges(dt) function returns a n x 2 index matrix we need to transpose for the right ordering
SegmentSequence(DT,@(dt) dt.Points(edges(dt)',:),'c');

% Circumcenters of each triangle in the DT triangulation
PointSequence(DT,@(dt) circumcenter(dt),"MarkerSize",1);

% Draw finite boundaries between Voronoi regions.
SegmentSequence(DT,@drawVoronoi,0,'m'); % This omits drawing of infinite boundaries.
cameraZoom(1);
camera(0.5,0.5);


function xy = drawVoronoi(dt)
    [C,r] = voronoiDiagram(dt); % kinda stupid but returns inf for all unbounded region vertices
    r = cellfun(@(x) [x 1],r,'UniformOutput',false);
    xy = C(horzcat(r{:}),:);
end