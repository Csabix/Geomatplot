function h = Midpoint(varargin)

    [parent,label,labels,args] = parseinputs(varargin{:});
    callback = @(varargin) mean(vertcat(varargin{:}));
    h = dpoint(parent,label,labels,callback,args);
    
end

function [parent,label,labels,args] = parseinputs(varargin)
    p = betterInputParser; ispositive = @(x)isnumeric(x) && isscalar(x) && x>=0;

    p.addOptional('Parent'     , [], @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
    p.addOptional('Label'      , [], @(x) isvarname(x));
    p.addOptional('Labels'     , [], @iscellstr);
    p.addOptional('Color'      ,'k', @drawing.isColorName);
    p.addParameter('MarkerSize', 6 , ispositive);
    p.addParameter('LabelAlpha', 0 , ispositive);

    p.KeepUnmatched = true;
    p.parse(varargin{:});
    res = p.Results;

    parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
    if isempty(res.Label); res.Label = parent.getNextCapitalLabel; end
    label = res.Label;
    labels = cell(1,length(res.Labels));
    for i=1:length(res.Labels)
        labels{i} = parent.getHandle(res.Labels{i});
    end
    res = rmfield(res,'Labels');
    res.LabelTextColor = res.Color;
    nams = [fieldnames(res) fieldnames(p.Unmatched)];
    vals = [struct2cell(res) struct2cell(p.Unmatched)];
    args(1:2:length(nams)*2) = nams(:);
    args(2:2:length(vals)*2) = vals(:);
end

