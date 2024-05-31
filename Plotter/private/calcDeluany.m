function [x, y, indices, pointsAdded] = calcDeluany(x,y)
    arguments
        x double
        y double
    end
    warning('off','all')
    count = numel(x);

    if isrow(x)
        P = [x',y'];
    else
        P = [x,y];
    end
    
    %C = zeros(count, 2);
    %for i = 1:(count-1)
    %    C(i,:) = [i, i + 1];
    %end
    %C(count,:) = [count, 1];
    C = [(1:count)',(2:count+1)'];
    C(count,2) = 1;
    
    DT = delaunayTriangulation(P,C);
    IO = isInterior(DT);
    indices = DT(IO, :);
    x = DT.Points(:,1);
    y = DT.Points(:,2);
    pointsAdded = numel(x) ~= count;
    warning('on','all')
end

