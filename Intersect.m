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
%   INTERSECT(___,color)  specifies the color of the intersection, the default is 'k'.
%
%   INTERSECT(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = INTERSECT(___)  returns the intersection points as an array of handles.
%
%   [h,g] = INTERSECT(___)  also returns the intersection point sequence object. This
%       allows more dynamic intersection number handling.
%
%   See also GEOMATPLOT


    [parent,labels,inputs,args] = parse(varargin{:});
    function v = intersect(a,b)
        [v(:,1), v(:,2)] = polyxpoly(a(:,1),a(:,2),b(:,1),b(:,2));
    end
    l = parent.getNextLabel('small');
    g_ = dpointseq(parent,l,inputs,@intersect,struct);
    
    for i = 1:length(labels)
        args.Label = labels{i};
        h_(i)=dpoint(parent,labels{i},{g_},@(x)x(i,:),args);
    end
    
    if nargout >= 1; h = h_; end
    if nargout == 2; g = g_; end
end

function [parent,labels,inputs,args] = parse(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);
    [labels,varargin] = parent.extractMultipleLabels(varargin,'capital');
    [parent,labels,inputs,args] = parse_(parent,labels,varargin{:});
    inputs = parent.getHandlesOfLabels(inputs);
end

function [parent,labels,inputs,args] = parse_(parent,labels,inputs,color,args)
    arguments
        parent          (1,1) Geomatplot
        labels          (1,:) cell      
        inputs          (1,:) cell      {drawing.mustBeInputList(inputs,parent)}
        color                           {drawing.mustBeColor}               = 'k'
        args.MarkerSize (1,1) double    {mustBePositive}                    = 6
        args.LabelAlpha (1,1) double    {mustBeInRange(args.LabelAlpha,0,1)}= 0
    end
    args.Color = color;
    args.LabelTextColor = color;
end

function [parent,label,inputs,args] = parseinputs(varargin) % todo
    p = betterInputParser; % ispositive = @(x)isnumeric(x) && isscalar(x) && x>=0;
    
    p.addOptional('Parent'     , [], @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
    p.addOptional('Label'      , [], @(x) isvarname(x) || iscellstr(x)); %todo
    p.addOptional('Labels'     , [], @drawing.isLabelList);
    %o.addOptional('Max')
    p.addOptional('Color'      ,'k', @drawing.isColorName);

    p.KeepUnmatched = true;
    p.parse(varargin{:});
    res = p.Results;

    parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
    if isempty(res.Label); res.Label = parent.getNextCapitalLabel; end
    label = res.Label;
    inputs = drawing.getHandlesOfLabels(parent,res.Labels);
    res = rmfield(res,{'Label','Labels'});
    
    args = [namedargs2cell(res) namedargs2cell(p.Unmatched)];
end
