function h = Point(varargin)

    [parent,label,args] = parseinputs(varargin{:});
    h = mpoint(parent,label,args);
    
end

function [parent,label,args] = parseinputs(varargin)
    p = betterInputParser; ispositive = @(x)isnumeric(x) && isscalar(x) && x>=0;

    p.addOptional('Parent'     , [], @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
    p.addOptional('Label'      , [], @isvarname);
    p.addOptional('Position'   , [], @isnumeric);
    p.addOptional('Color'      ,'b', @drawing.isColorName);
    p.addParameter('MarkerSize', 8 , ispositive);
    p.addParameter('LabelAlpha', 0 , ispositive);

    p.KeepUnmatched = true;
    p.parse(varargin{:});
    res = p.Results;

    parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
    if isempty(res.Label); res.Label = parent.getNextCapitalLabel; end
    label = res.Label;
    if isempty(res.Position); res = rmfield(res,'Position'); end
    res.LabelTextColor = res.Color;
    nams = [fieldnames(res) fieldnames(p.Unmatched)];
    vals = [struct2cell(res) struct2cell(p.Unmatched)];
    args(1:2:length(nams)*2) = nams(:);
    args(2:2:length(vals)*2) = vals(:);
end

