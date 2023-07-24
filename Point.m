function h = Point(varargin)
% todo write help

    [parent,label,args] = parse_mpoint_inputs(varargin{:});
    h_ = mpoint(parent,label,args);
    
    if nargout == 1; h=h_; end
end

function [parent,label,args] = parse_mpoint_inputs(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'capital');
    [position,varargin] = drawing.extractPosition(varargin);
    [parent,label,args] = parse_mpoint_inputs_(parent,label,position,varargin{:});
end

function [parent,label,args] = parse_mpoint_inputs_(parent,label,position,color,args)
    arguments
        parent          (1,1) Geomatplot
        label           (1,:) char      {mustBeValidVariableName}
        position        (:,2) double    {mustBeReal}
        color                           {drawing.mustBeColor}               = 'b'
        args.MarkerSize (1,1) double    {mustBePositive}                    = 8
        args.LabelAlpha (1,1) double    {mustBeInRange(args.LabelAlpha,0,1)}= 0
    end
    args.Label = label;
    args.Color = color;
    args.LabelTextColor = color;
    if ~isempty(position); args.Position = position; end
end


% function [parent,label,args] = parseinputs(varargin)
%     p = betterInputParser; ispositive = @(x)isnumeric(x) && isscalar(x) && x>=0;
% 
%     p.addOptional('Parent'     , [], @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
%     p.addOptional('Label'      , [], @isvarname);
%     p.addOptional('Position'   , [], @isnumeric);
%     p.addOptional('Color'      ,'b', @drawing.isColorName);
%     p.addParameter('MarkerSize', 8 , ispositive);
%     p.addParameter('LabelAlpha', 0 , ispositive);
% 
%     p.KeepUnmatched = true;
%     p.parse(varargin{:});
%     res = p.Results;
% 
%     parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
%     if isempty(res.Label); res.Label = parent.getNextCapitalLabel; end
%     label = res.Label;
%     if isempty(res.Position); res = rmfield(res,'Position'); end
%     res.LabelTextColor = res.Color;
%     nams = [fieldnames(res) fieldnames(p.Unmatched)];
%     vals = [struct2cell(res) struct2cell(p.Unmatched)];
%     args(1:2:length(nams)*2) = nams(:);
%     args(2:2:length(vals)*2) = vals(:);
% end

