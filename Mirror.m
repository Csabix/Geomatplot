function h = Mirror(varargin)

    eidType = 'Mirror:invalidInputPattern';
    msgType = 'Cannot mirror for these input types.';

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label, varargin] = parent.extractLabel(varargin,'none');
    [inputs,varargin] = parent.extractInputs(varargin,2,3);
    if isempty(label); label = parent.getNextLabel(inputs{1}.label); end

    if isa(inputs{1},'point_base')
        if drawing.isInputPatternMatching(inputs,{'drawing','point_base'})
            callback = @mirror_point2point;
        elseif drawing.isInputPatternMatching(inputs,{'drawing','point_base','point_base'})
            callback = @mirror_point2segment;
        elseif drawing.isInputPatternMatching(inputs,{'drawing','dpointseq'})
            callback = @mirror_point2pointseq;
        elseif drawing.isInputPatternMatching(inputs,{'drawing','dcircle'})
            callback = @mirror_point2circle; 
        elseif drawing.isInputPatternMatching(inputs,{'drawing',{'dlines','polygon_base'}})
            callback = @mirror_point2polyline;
        else
            throw(MException(eidType,msgType));
        end
        args = dpoint.parse_inputs_(varargin{:});
        args.Label = label;
        h_ = dpoint(parent,label,inputs,callback,args);
    elseif isa(inputs{1},'dcircle')
        if drawing.isInputPatternMatching(inputs,{'drawing','point_base'})
            % do nothing
        elseif drawing.isInputPatternMatching(inputs,{'drawing','point_base','point_base'})
            % do nothing
        else
            throw(MException(eidType,msgType));
        end
        args = dlines.parse_inputs_(varargin{:});
        c_ = Mirror(parent,[{inputs{1}.center},inputs(2:end)],'LabelVisible','off','MarkerSize',5);
        h_ = dcircle(parent,label,c_,inputs{1}.radius,args);
    elseif isa(inputs{1},'dlines') || isa(inputs{1},'polygon_base')  % includes dcurves
        if drawing.isInputPatternMatching(inputs,{'drawing','point_base'})
            callback = @mirror_point2point;
        elseif drawing.isInputPatternMatching(inputs,{'drawing','point_base','point_base'})
            callback = @mirror_point2segment;
        else
            throw(MException(eidType,msgType));
        end
        args = dlines.parse_inputs_(varargin{:});
        h_ = dlines(parent,label,inputs,callback,args);
    else
        throw(MException(eidType,msgType));        
    end

    if nargout >=1; h=h_; end
end

function a = mirror_point2point(a,b)
    a = 2*b.value-a.value;
end

function p = mirror_point2segment(p,a,b)
    p = p.value; a = a.value;
    n = (b.value-a)*[0 1; -1 0];
    a = p - a;
    p = p - 2*(n(1)*a(:,1)+n(2)*a(:,2))*n/(n(1).^2+n(2).^2);
end

function p = mirror_point2pointseq(p,s)
    s = s.value;    p = p.value-s;
    [~,id] = min(sqrt(p(:,1).^2 + p(:,2).^2));
    p = s(id,:)-p(id,:);
end

function v = mirror_point2circle(p,c)
    v = p.value-c.center.value;
    v = 2*c.radius.value/sqrt(v(1)^2+v(2)^2)*v + c.center.value - v;
end

function p = mirror_point2polyline(p,polyline)
    polyline = polyline.value; p  = p.value;
    xv = polyline(:,1) - p(1); dx = diff(xv);
    yv = polyline(:,2) - p(2); dy = diff(yv);       

    t = min(1,max(0,...
            -(xv(1:end-1).*dx + yv(1:end-1).*dy) ./ (dx.^2 + dy.^2)...
        ));

    dx = xv(1:end-1) + t.*dx;
    dy = yv(1:end-1) + t.*dy;
    [~,idx] = min(dx.^2 + dy.^2);
    p = p + 2*[dx(idx) dy(idx)];
end