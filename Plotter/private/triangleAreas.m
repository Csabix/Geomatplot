function areas = triangleAreas(positions, indices)
    triangleCount = size(indices,1);
    
    areas = zeros(triangleCount,1);

    for i = 1:triangleCount
        mat = [positions(indices(i,1),:),1;
               positions(indices(i,2),:),1;
               positions(indices(i,3),:),1];
        areas(i) = det(mat);
    end
end

