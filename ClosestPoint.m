function h = ClosestPoint(varargin)

    [parent,label,inputs,args] = dpoint.parse_inputs(varargin{:});
    drawing.mustBeOfLength(inputs,2);

    if drawing.isInputPatternMatching(inputs,{'point_base',{'point_base','dpointseq'}})
        callback = @closest_point2pointseq;
    elseif drawing.isInputPatternMatching(inputs,{'point_base','dcircle'})
        callback = @closest_point2circle; 
    elseif drawing.isInputPatternMatching(inputs,{'point_base',{'dlines','mpolygon'}})
        callback = @closest_point2polyline;
    else
        eidType = 'ClosestPoint:invalidInputPattern';
        msgType = 'Cannot find closest point for these input types';
        throw(MException(eidType,msgType));
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