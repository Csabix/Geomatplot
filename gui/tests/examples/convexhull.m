clf;
n = 30; % number of points
pts = cell(1,n); rng(1);
for i = 1:n
    pts{i} = Point(rand(1,2)); % draw draggable points at random
end
pts = PointSequence(pts);

slider = drawSliderX([0 1],[1 1]);

AS = CustomValue(pts,slider,@alphaShape);
SegmentSequence(AS,@(as) as.Points(boundaryFacets(as)',:),'c');

Point('GeomMed',pts,@weiszfeld_algorithm,'r');

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