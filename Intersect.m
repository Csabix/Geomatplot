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


    [parent,label,labels,args] = parseinputs(varargin{:});
    function v = intersect(a,b)
        [v(:,1), v(:,2)] = polyxpoly(a(:,1),a(:,2),b(:,1),b(:,2));
    end
    g = dpointseq(parent,label,labels,@intersect,args);
    if isinteger(label)
        for i=1:label
            ll = parent.getNextCapitalLabel;
            newargs = {'Label',ll,'LabelAlpha',0,'LabelTextColor','k'};
            h(i) = dpoint(parent,ll,{g},@(x)x(i,:),[newargs args]);
        end
    elseif isvarname(label)
        newargs = {'Label',label,'LabelAlpha',0,'LabelTextColor','k'};
        h = dpoint(parent,label,{g},@(x) x(1,:),[newargs args]);
    elseif iscellstr(label)
        for i=1:length(label)
            ll = label{i};
            newargs = {'Label',ll,'LabelAlpha',0,'LabelTextColor','k'};
            h(i) = dpoint(parent,ll,{g},@(x)x(i,:),[newargs args]);
        end
    end

end

function [parent,label,labels,args] = parseinputs(varargin) % todo
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
    labels = drawing.getHandlesOfLabels(parent,res.Labels);
    res = rmfield(res,{'Label','Labels'});
    
    args = [namedargs2cell(res) namedargs2cell(p.Unmatched)];
end
