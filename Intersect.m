function [h,g] = Intersect(varargin)
% INTERSECT  intersects two Geomatplot curves
%   INTERSECT({a,b})  intersects curve a and b producing a single intersection point.
%       If there are more intersection points, only the first one found will be shown.
%       If no intersections occur, the intersection point will still exist but will be
%       in an undefined state. Inputs a and b may be labels of existing curves. The
%       intersection point is assigned a label automatically.
%
%   INTERSECT(label,{a,b})  provides a label for the intersection point.
%
%   INTERSECT(N,{a,b})  creates N number of intersection points between curves a and b.
%       If there M < N intersections, then the last N-M number of intersections will be
%       undefined. Label assignement is automatic.
%
%   INTERSECT({label1,label2,...},{a,b})  assignes labels to multiple intersections.
%       The number of given labels determine the number of intersection points created.
%
%   INTERSECT(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one.
%
%   INTERSECT(___,color)  specifies the color of the intersection, the default is 'k'. This may
%       be a colorname or a three element vector.
%
%   INTERSECT(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = INTERSECT(___)  returns the intersection points as an array of handles.
%
%   [h,g] = INTERSECT(___)  also returns the intersection point sequence object. This
%       allows more dynamic intersection number handling.
%
%   See also GEOMATPLOT, SEGMENT, POLYGON, CURVE

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);
    [labels,varargin] = parent.extractMultipleLabels(varargin,'capital');
    [inputs,varargin] = parent.extractInputs(varargin,2,2);
    [args  ,s]        = parse_(varargin{:});

    if drawing.isInputPatternMatching(inputs,{'dcircle','dcircle'})
        callback = @intersect_circle2circle;
    elseif drawing.isInputPatternMatching(inputs,{'dcircle',{'dlines','mpolygon'}})
        callback = @intersect_circle2polyline;
    elseif drawing.isInputPatternMatching(inputs,{{'dlines','mpolygon'},'dcircle'})
        callback = @intersect_circle2polyline;
        inputs = inputs([2 1]);
    elseif drawing.isInputPatternMatching(inputs,{{'dlines','mpolygon'},{'dlines','mpolygon'}})
        callback = @intersect_poly2poly;
    end

    l = parent.getNextLabel('ptseq');
    g_ = dpointseq(parent,l,inputs,callback,s);
    drawing.mustBeOfLength(inputs,2);
    
    for i = 1:length(labels)
        args.Label = labels{i};
        try
            h_(i) = dpoint(parent,labels{i},{g_}, @(x) x.value(i), args);
        catch ME
            if ~strcmp(ME.identifier,'MATLAB:badsubscript')
                rethrow(ME);
            end
        end
    end
    
    if nargout >= 1
        if isempty(labels)
            h = [];
        else
            h = h_;
        end
    end
    if nargout == 2; g = g_; end
end

function v = intersect_poly2poly(a,b)
% maybe try this? https://www.mathworks.com/matlabcentral/fileexchange/22444-minimum-distance-between-two-polygons
    a = a.value; b = b.value; 
    [v(:,1), v(:,2)] = polyxpoly(a(:,1),a(:,2),b(:,1),b(:,2));
end

function v = intersect_circle2polyline(c,p)
    p = p.value;
    a = p(1:end-1,:);
    ab = diff(p,1);
    ac = a - c.center.value;
    A = dot(ab,ab,2);
    B = 2*dot(ab,ac,2);
    %C = dot(ac,ac,2)-c.radius.value.^2;
    d = B.*B-4.*A.*(dot(ac,ac,2)-c.radius.value.^2);
    l = d>0;
    A  = [A(l)    ; A(l)   ];
   %B  = [B(l)    ; B(l)   ];
    a  = [a(l,:)  ; a(l,:) ];
    ab = [ab(l,:) ; ab(l,:)];
    d  = sqrt(d(l)); %d = [d; -d]; %both signes

    t = -0.5*([B(l);B(l)]+[d;-d])./A;
    l = 0<t & t<1;
    %t2 = 0.5*(-B+sign(A).*d)./A;
    %b2 = 0<t2 & t2<1;

    %v  = [ a(l,:)+ab(l,:).*t(l) ; a(b2,:)+ab(b2,:).*t2(b2) ];
    v = a(l,:)+ab(l,:).*t(l);
end

function v = intersect_circle2circle(c0,c1)
    o0 = c0.center.value; %o1 = c1.center.value;
    o01 = c1.center.value - o0;
    d2 = 1/(o01(1)^2+o01(2)^2);
    R2 = c0.radius.value.^2*d2;
    r2 = c1.radius.value.^2*d2;
    t = 0.5 + 0.5*(R2 - r2);
    s = R2 - t^2;
    if s > 0
        s = sqrt(s);
        v = o0 + t*o01 + [s;-s]*o01*[0 1; -1 0];
    else
        v = zeros(0,2);
    end
end

function [args,s] = parse_(color,args,s)
    arguments
        color                           {drawing.mustBeColor}               = 'k'
        args.MarkerSize (1,1) double    {mustBePositive}                    = 7
        args.LabelAlpha (1,1) double    {mustBeInRange(args.LabelAlpha,0,1)}= 0
        args.LabelTextColor             {drawing.mustBeColor}
        args.LineWidth  (1,1) double    {mustBePositive}
        s.SMarkerEdgeColor              {drawing.mustBeColor}               = [.7 .7 .7]
        s.SMarkerFaceColor              {drawing.mustBeColor}               = [.4 .4 .4]
        s.SLineWidth    (1,1) double    {mustBePositive}                    = 0.5
        s.SMarkerSize   (1,1) double    {mustBePositive}                    = 18
        s.SMarkerColor                  {drawing.mustBeColor}               = 'k'
        s.SMarkerSymbol (1,:) char      {mustBeMember(s.SMarkerSymbol,{'o','+','*','x','_','|','^','v','>','<','square','diamond','pentagram','hexagram'})}='o'
    end
    args.Color = color;
    if ~isfield(args,'LabelTextColor'); args.LabelTextColor = color; end
end
