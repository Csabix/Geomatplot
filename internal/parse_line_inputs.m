function [parent,label,labels,args] = parse_line_inputs(nargs,varargin)
    p = betterInputParser; ispositive = @(x)isnumeric(x) && isscalar(x) && x>=0;

    p.addOptional('Parent'     , [], @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
    p.addOptional('Label'      , [], @isvarname);
    p.addOptional('Labels'     , {}, @(x) drawing.isLabelList(x) && any(length(x)==nargs));
    p.addOptional('LineSpec'   ,'k-', @drawing.matchLineSpec);
    p.addParameter('LineWidth' , 1.5, ispositive);

    p.KeepUnmatched = true;
    p.parse(varargin{:});
    res = p.Results;

    parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
    if isempty(res.Label); res.Label = parent.getNextSmallLabel; end
    label = res.Label; res = rmfield(res,'Label');
    labels = drawing.getHandlesOfLabels(parent,res.Labels);
    [~,LineStyle, Marker, Color] = drawing.matchLineSpec(res.LineSpec);
    
    if ~isempty(LineStyle); res.LineStyle = LineStyle; end
    if ~isempty(Marker); res.Marker = Marker; end
    if ~isempty(Color); res.Color = Color; else; res.Color='k'; end

    res = rmfield(res,{'Labels','LineSpec'});
    
    args = [drawing.struct2arglist(res) drawing.struct2arglist(p.Unmatched)];
end