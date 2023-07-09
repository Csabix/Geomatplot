function [parent,label,labels,args] = parse_line_inputs(nargs,varargin)
    p = betterInputParser; ispositive = @(x)isnumeric(x) && isscalar(x) && x>=0;

    p.addOptional('Parent'     , [], @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
    p.addOptional('Label'      , [], @isvarname);
    p.addOptional('Labels'     , {}, @(x) iscellstr(x) && any(length(x)==nargs));
    p.addOptional('Color'      ,'k', @drawing.isColorName);
    p.addParameter('LineWidth' , 2 , ispositive);

    p.KeepUnmatched = true;
    p.parse(varargin{:});
    res = p.Results;

    parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
    if isempty(res.Label); res.Label = parent.getNextCapitalLabel; end
    label = res.Label; res = rmfield(res,'Label');
    labels = cell(1,length(res.Labels));
    for i=1:length(res.Labels)
        labels{i} = parent.getHandle(res.Labels{i});
    end
    res = rmfield(res,'Labels');
    nams = [fieldnames(res) fieldnames(p.Unmatched)];
    vals = [struct2cell(res) struct2cell(p.Unmatched)];
    args(1:2:length(nams)*2) = nams(:);
    args(2:2:length(vals)*2) = vals(:);
end