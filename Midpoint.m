function h = Midpoint(varargin)

    [parent,label,inputs,args] = parse_dpoint_inputs(varargin{:});
    callback = @(varargin) mean(vertcat(varargin{:}));
    for i = 1:length(inputs)
        l = inputs{i};
        if isa(l,'dcurve') || isa(l,'dimage')
            eidType = 'Midpoint:invalidInput';
            msgType = 'The input drawing cannot be of this type.';
            throw(MException(eidType,msgType));
        end
    end
    h = dpoint(parent,label,inputs,callback,args);
    
end

function [parent,label,inputs,args] = parse_dpoint_inputs(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'capital');
    [parent,label,inputs,args] = parse_dpoint_inputs_(parent,label,varargin{:});
    inputs = parent.getHandlesOfLabels(inputs);
end

function [parent,label,inputs,args] = parse_dpoint_inputs_(parent,label,inputs,color,args)
    arguments
        parent          (1,1) Geomatplot
        label           (1,:) char      {mustBeValidVariableName}
        inputs          (1,:) cell      {drawing.mustBeInputList(inputs,parent)}
        color                           {drawing.mustBeColor}               = 'k'
        args.MarkerSize (1,1) double    {mustBePositive}                    = 6
        args.LabelAlpha (1,1) double    {mustBeInRange(args.LabelAlpha,0,1)}= 0
    end
    args.Label = label;
    args.Color = color;
    args.LabelTextColor = color;
end


% function [parent,label,labels,args] = parseinputs(varargin)
%     p = betterInputParser; ispositive = @(x)isnumeric(x) && isscalar(x) && x>=0;
% 
%     p.addOptional('Parent'     , [], @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
%     p.addOptional('Label'      , [], @isvarname);
%     p.addOptional('Labels'     , [], @drawing.isLabelList);
%     p.addOptional('Color'      ,'k', @drawing.isColorName);
%     p.addParameter('MarkerSize', 6 , ispositive);
%     p.addParameter('LabelAlpha', 0 , ispositive);
% 
%     p.KeepUnmatched = true;
%     p.parse(varargin{:});
%     res = p.Results;
% 
%     parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
%     if isempty(res.Label); res.Label = parent.getNextCapitalLabel; end
%     label = res.Label;
%     labels = drawing.getHandlesOfLabels(parent,res.Labels);
%     res = rmfield(res,'Labels');
%     res.LabelTextColor = res.Color;
%     
%     args = [namedargs2cell(res) namedargs2cell(p.Unmatched)];
% end

