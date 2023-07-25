function h = Distance(varargin)
    
    [parent,label,inputs] = parse(varargin{:});
    
    if drawing.isInputPatternMatching(inputs,{'point_base','point_base'}) || drawing.isInputPatternMatching(inputs,{'point_base','dpointseq'})
        %callback = @(a,b) sqrt((a(1)-b(:,1)).^2 + (a(2)-b(:,2)).^2);
        callback = @dist_point2pointseq;
%    elseif drawing.isInputPatternMatching(inputs,{'point_base','dcircle'})
%        callback = @(a,b)
    elseif drawing.isInputPatternMatching(inputs,{'point_base','dlines'})
        callback = @dist_point2polyline;
    else
        eidType = 'Distance:invalidInputPattern';
        msgType = 'Cannot measure distance between these input types';
        throw(MException(eidType,msgType));
    end

    h_ = dscalar(parent,label,inputs,callback);
    
    if nargout == 1; h = h_; end
end

function v = dist_point2pointseq(a,b)
    c = a.value-b.value;
    v = sqrt(c(:,1).^2 + c(:,2).^2);
end

function [parent,label,inputs] = parse(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'small');
    [parent,label,inputs] = parse_(parent,label,varargin{:});
    inputs = parent.getHandlesOfLabels(inputs);
end

function [parent,label,inputs] = parse_(parent,label,inputs)
    arguments
        parent          (1,1) Geomatplot
        label           (1,:) char      {mustBeValidVariableName}
        inputs          (1,:) cell      {drawing.mustBeInputList(inputs,parent)}
    end
end

function d = dist_point2polyline(p,polyline)
    %https://www.mathworks.com/matlabcentral/fileexchange/12744-distance-from-points-to-polyline-or-polygon
    polyline = polyline.value; p = p.value;
    xv = polyline(:,1); yv = polyline(:,2);
    
    % linear parameters of segments that connect the vertices
    dx =  diff(xv);    dy = -diff(yv);
    C = yv(2:end).*xv(1:end-1) - xv(2:end).*yv(1:end-1);

    % find the projection of point (x,y) on each rib
    AB = 1./(dy.^2 + dx.^2);
    vv = (dy*p(1)+dx*p(2)+C);
    xp = p(1) - (dy.*AB).*vv;
    yp = p(2) - (dx.*AB).*vv;

    % find all cases where projected point is inside the segment
    idx_x = (((xp>=xv(1:end-1)) & (xp<=xv(2:end))) | ((xp>=xv(2:end)) & (xp<=xv(1:end-1))));
    idx_y = (((yp>=yv(1:end-1)) & (yp<=yv(2:end))) | ((yp>=yv(2:end)) & (yp<=yv(1:end-1))));
    idx = idx_x & idx_y;

    % distance from point (x,y) to the vertices
    dv = sqrt((xv(1:end-1)-p(1)).^2 + (yv(1:end-1)-p(2)).^2);
    if(~any(idx)) % all projections are outside of polygon ribs
       d = min(dv);
    else
       % distance from point (x,y) to the projection on ribs
       dp = sqrt((xp(idx)-p(1)).^2 + (yp(idx)-p(2)).^2);
       d = min(min(dv), min(dp));
    end
end