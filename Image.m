function h = Image(callback,varargin)
    [parent,label,labels,corner0,corner1,args] = parseinputs(varargin{:});
    h = dimage(parent,label,labels,callback,corner0,corner1,args);
end

function [parent,label,labels,corner0,corner1,args] = parseinputs(varargin)
    p = betterInputParser;
    ispoint = @(x)(isnumeric(x) && length(x)==2 && x(2)>x(1)) || isa(x,'point_base');

    p.addOptional('Parent'     , []   , @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
    p.addOptional('Label'      , []   , @(x) isvarname(x));
    p.addOptional('Labels'     , []   , @drawing.isLabelList);
    p.addOptional('Corner0'    , [0 0], ispoint);
    p.addOptional('Corner1'    , [1 1], ispoint);

    p.KeepUnmatched = true;
    p.parse(varargin{:});
    res = p.Results;

    parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
    if isempty(res.Label); res.Label = parent.getNextCapitalLabel; end
    label = res.Label; corner0 = res.Corner0; corner1 = res.Corner1;
    labels = drawing.getHandlesOfLabels(parent,res.Labels);
    res = rmfield(res,{'Label','Labels','Corner0','Corner1'});
    
    args = [drawing.struct2arglist(res) drawing.struct2arglist(p.Unmatched)];
end
