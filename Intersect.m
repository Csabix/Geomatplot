function h = Intersect(varargin)

    [parent,label,labels,args] = parseinputs(varargin{:});
    function v = intersect(a,b)
        [v(:,1), v(:,2)] = polyxpoly(a(:,1),a(:,2),b(:,1),b(:,2));
    end
    g = dpointseq(parent,label,labels,@intersect,args);
    num = 1; %todo
    for i=1:num
        ll = [label,num2str(i)];
        newargs = {'Label',ll,'LabelAlpha',0,'LabelTextColor','k'};
        h(i) = dpoint(parent,ll,{g},@(x)x(i,:),[newargs args]);
    end
end

function [parent,label,labels,args] = parseinputs(varargin) % todo
    p = betterInputParser; % ispositive = @(x)isnumeric(x) && isscalar(x) && x>=0;

    p.addOptional('Parent'     , [], @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
    p.addOptional('Label'      , [], @(x) isvarname(x));
    p.addOptional('Labels'     , [], @drawing.isLabelList);
    p.addOptional('Color'      ,'k', @drawing.isColorName);

    p.KeepUnmatched = true;
    p.parse(varargin{:});
    res = p.Results;

    parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
    if isempty(res.Label); res.Label = parent.getNextCapitalLabel; end
    label = res.Label;
    labels = drawing.getHandlesOfLabels(parent,res.Labels);
    res = rmfield(res,{'Label','Labels'});
    
    args = [drawing.struct2arglist(res) drawing.struct2arglist(p.Unmatched)];
end
