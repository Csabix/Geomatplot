function h = ClosestPoint(varargin)
    
    callback_only = nargin >= 1 && strcmp(varargin{1},'internal');
    if callback_only; varargin = varargin(2:end); end
    
    [parent,label,inputs,args] = dpoint.parse_inputs(varargin,'capital',2,2);

    if drawing.isInputPatternMatching(inputs,{'point_base',{'point_base','dpointseq'}})
        callback = @closest_point2pointseq;
    elseif drawing.isInputPatternMatching(inputs,{'point_base','dcircle'})
        callback = @closest_point2circle; 
    elseif drawing.isInputPatternMatching(inputs,{'point_base','dlines'})
        callback = @closest_point2polyline;
    elseif drawing.isInputPatternMatching(inputs,{'point_base','polygon_base'})
        callback = @closes_point2polygonarea;
    else
        eidType = 'ClosestPoint:invalidInputPattern';
        msgType = 'Cannot find closest point for these input types';
        throw(MException(eidType,msgType));
    end
    if callback_only
        h = callback;
        return;
    end
    h_ = dpoint(parent,label,inputs,callback,args);

    if nargout >=1; h=h_; end
end

function p = closest_point2pointseq(p,s)
    s = s.value - p.value;
    [~,id] = min(s(:,1).^2 + s(:,2).^2);
    p = s(id,:) + p.value;
end

function p = closest_point2circle(p,c)
    p = p.value-c.center.value;
    p = c.radius.value/sqrt(p(1)^2+p(2)^2)*p + c.center.value;
end

function p = closest_point2polyline(p,polyline)
    polyline = polyline.value; p  = p.value;
    xv = polyline(:,1) - p(1); dx = diff(xv);
    yv = polyline(:,2) - p(2); dy = diff(yv);       

    t = min(1,max(0,...
            -(xv(1:end-1).*dx + yv(1:end-1).*dy) ./ (dx.^2 + dy.^2)...
        ));

    dx = xv(1:end-1) + t.*dx;
    dy = yv(1:end-1) + t.*dy;
    [~,idx] = min(dx.^2 + dy.^2);
    p = [dx(idx) dy(idx)] + p;
end

function p = closes_point2polygonarea(p,polygon)
    polyline = polygon.value; p  = p.value;
    in = inpolygon(p(1),p(2),polyline(:,1),polyline(:,2));
    if in; return; end
    % the rest is the same as closest_point2polyline
    xv = polyline(:,1) - p(1); dx = diff(xv);
    yv = polyline(:,2) - p(2); dy = diff(yv);       

    t = min(1,max(0,...
            -(xv(1:end-1).*dx + yv(1:end-1).*dy) ./ (dx.^2 + dy.^2)...
        ));

    dx = xv(1:end-1) + t.*dx;
    dy = yv(1:end-1) + t.*dy;
    [~,idx] = min(dx.^2 + dy.^2);
    p = [dx(idx) dy(idx)] + p;
end