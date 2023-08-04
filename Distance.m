function h = Distance(varargin)
% Distance  creates a dependent scalar holding the distance between two Geomaplot geometries.
%
%   Distance({A,B}) creates a dependent Geomatplot scalar with the distance between A and B points.
%
%   Distance({A,geom}) distance between a point and most geometries
%
%   Distance(label,___)  provides a label for the point.
%
%   Distance(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. Thus must preceed the label argument if that is given also.
%
%   h = Distance(___)  returns the created handle.
%
%   See also CIRCLE

    [parent,label,inputs] = parse(varargin{:});
    
    if drawing.isInputPatternMatching(inputs,{'point_base',{'point_base','dpointseq'}})
        callback = @dist_point2pointseq;
    elseif drawing.isInputPatternMatching(inputs,{'point_base','dcircle'})
        callback = @dist_point2circle; 
    elseif drawing.isInputPatternMatching(inputs,{'point_base',{'dlines','mpolygon'}})
        callback = @dist_point2polyline;
    else
        eidType = 'Distance:invalidInputPattern';
        msgType = 'Cannot measure distance between these input types';
        throw(MException(eidType,msgType));
    end

    h_ = dscalar(parent,label,inputs,callback);
    
    if nargout == 1; h = h_; end
end

function v = dist_point2circle(p,c)
    v = p.value - c.center.value;
    v = abs(sqrt(v(1).^2 + v(2).^2) - c.radius.value);
end

function d = dist_point2pointseq(a,b)
    a = a.value-b.value;
    d = sqrt(min(a(:,1).^2 + a(:,2).^2));
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
        inputs          (1,2) cell      {drawing.mustBeInputList(inputs,parent)}
    end
end

function d = dist_point2polyline(p,polyline)
    polyline = polyline.value; p  = p.value;
    xv = polyline(:,1) - p(1); dx = diff(xv);
    yv = polyline(:,2) - p(2); dy = diff(yv);       

    t = min(1,max(0,...
            -(xv(1:end-1).*dx + yv(1:end-1).*dy) ./ (dx.^2 + dy.^2)...
        ));

    d = sqrt(min( (xv(1:end-1) + t.*dx).^2 + (yv(1:end-1) + t.*dy).^2 ));
end