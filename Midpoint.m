function h = Midpoint(varargin)

    [parent,label,labels,args] = parseinputs(varargin{:});
    callback = @(varargin) mean(vertcat(varargin{:}));
    h = dpoint(parent,label,labels,callback,args);
    
end

function [parent,label,labels,args] = parseinputs(varargin)
    p = betterInputParser; ispositive = @(x)isnumeric(x) && isscalar(x) && x>=0;

    p.addOptional('Parent'     , [], @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
    p.addOptional('Label'      , [], @isvarname);
    p.addOptional('Labels'     , [], @drawing.isLabelList);
    p.addOptional('Color'      ,'k', @drawing.isColorName);
    p.addParameter('MarkerSize', 6 , ispositive);
    p.addParameter('LabelAlpha', 0 , ispositive);

    p.KeepUnmatched = true;
    p.parse(varargin{:});
    res = p.Results;

    parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
    if isempty(res.Label); res.Label = parent.getNextCapitalLabel; end
    label = res.Label;
    labels = drawing.getHandlesOfLabels(parent,res.Labels);
    res = rmfield(res,'Labels');
    res.LabelTextColor = res.Color;
    
    args = [namedargs2cell(res) namedargs2cell(p.Unmatched)];
end

