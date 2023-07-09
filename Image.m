function h = Image(callback,varargin)
    [parent,label,labels,xrange,yrange,args] = parseinputs(varargin{:});
    h = dimage(parent,label,labels,callback,xrange,yrange,args);
end

function [parent,label,labels,xrange,yrange,args] = parseinputs(varargin)
    p = betterInputParser; isrange = @(x)isnumeric(x) && length(x)==2 && x(2)>x(1);

    p.addOptional('Parent'     , []   , @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
    p.addOptional('Label'      , []   , @(x) isvarname(x));
    p.addOptional('Labels'     , []   , @drawing.isLabelList);
    p.addOptional('XRange'     , [0 1], isrange);
    p.addOptional('YRange'     , [0 1], isrange);

    p.KeepUnmatched = true;
    p.parse(varargin{:});
    res = p.Results;

    parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
    if isempty(res.Label); res.Label = parent.getNextCapitalLabel; end
    label = res.Label; xrange = res.XRange; yrange = res.YRange;
    labels = drawing.getHandlesOfLabels(parent,res.Labels);
    res = rmfield(res,{'Label','Labels','XRange','YRange'});
    
    args = [drawing.struct2arglist(res) drawing.struct2arglist(p.Unmatched)];
end
