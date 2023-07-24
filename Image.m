function h = Image(callback,varargin)
    [parent,label,inputs,corner0,corner1] = parse_image_inputs(varargin{:});
    if nargin(callback) ~= length(inputs)+2
        eidType = 'Image:callbackWrongNumberOfArguments';
        msgType = ['Callback needs ' int2str(length(inputs)+2) ' number of arguments with the\n' ...
                   'first two being the X and Y sample positions.'];
        throw(MException(eidType,msgType));
    end
    h_ = dimage(parent,label,inputs,callback,corner0,corner1,{});

    if nargout == 1; h=h_; end
end

function [parent,label,inputs,corner0,corner1] = parse_image_inputs(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'capital');
    [parent,label,inputs,corner0,corner1]= parse_image_inputs_(parent,label,varargin{:});
    inputs = parent.getHandlesOfLabels(inputs);
end

function [parent,label,inputs,corner0,corner1] = parse_image_inputs_(parent,label,inputs,corner0,corner1)
    arguments
        parent          (1,1) Geomatplot
        label           (1,:) char      {mustBeValidVariableName}
        inputs          (1,:) cell      {drawing.mustBeInputList(inputs,parent)}
        corner0                         {mustBePoint} = [0 0]
        corner1                         {mustBePoint} = [1 1]
    end
end

function mustBePoint(x)
    if ~(isnumeric(x) && length(x)==2 || isa(x,'point_base'))
        eidType = 'mustBePoint:notPoint';
        msgType = 'The input must be a position or a point drawing';
        throwAsCaller(MException(eidType,msgType));
    end
end

% function [parent,label,labels,corner0,corner1,args] = parseinputs(varargin)
%     p = betterInputParser;
%     ispoint = @(x)(isnumeric(x) && length(x)==2 || isa(x,'point_base');
% 
%     p.addOptional('Parent'     , []   , @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
%     p.addOptional('Label'      , []   , @isvarname);
%     p.addOptional('Labels'     , []   , @drawing.isLabelList);
%     p.addOptional('Corner0'    , [0 0], ispoint);
%     p.addOptional('Corner1'    , [1 1], ispoint);
% 
%     p.KeepUnmatched = true;
%     p.parse(varargin{:});
%     res = p.Results;
% 
%     parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
%     if isempty(res.Label); res.Label = parent.getNextCapitalLabel; end
%     label = res.Label; corner0 = res.Corner0; corner1 = res.Corner1;
%     labels = drawing.getHandlesOfLabels(parent,res.Labels);
%     res = rmfield(res,{'Label','Labels','Corner0','Corner1'});
%     
%     args = [namedargs2cell(res) namedargs2cell(p.Unmatched)];
% end
