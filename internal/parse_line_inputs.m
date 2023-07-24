function [parent,label,inputs,linespec,args] = parse_line_inputs(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);   
    [label,varargin] = parent.extractLabel(varargin,'small');
    [parent,label,inputs,linespec,args] = parse_line_inputs_(parent,label,varargin{:});
    inputs = parent.getHandlesOfLabels(inputs);
end


function [parent,label,inputs,linespec,args] = parse_line_inputs_(parent,label,inputs,linespec,args)
    arguments
        parent         (1,1) Geomatplot
        label          (1,:) char       {mustBeValidVariableName}
        inputs         (1,:) cell       {drawing.mustBeInputList(inputs,parent)}
        linespec       (1,:) char       {drawing.mustBeLineSpec}        = 'k'
        args.LineWidth (1,1) double     {mustBePositive}                = 1.5
        args.LineStyle (1,:) char
        args.Marker    (1,:) char
        args.Color                      {drawing.mustBeColor}           = 'k'
    end
end


% function [parent,label,labels,args] = parse_line_inputs(nargs,varargin)
%     p = betterInputParser; ispositive = @(x)isnumeric(x) && isscalar(x) && x>=0;
% 
%     p.addOptional('Parent'     , [], @(x) isa(x,'Geomatplot') || isa(x,'matlab.graphics.axis.Axes') || isa(x,'matlab.ui.Figure'));
%     p.addOptional('Label'      , [], @isvarname);
%     p.addOptional('Labels'     , {}, @(x) drawing.isLabelList(x) && any(length(x)==nargs));
%     p.addOptional('LineSpec'   ,'k-', @drawing.matchLineSpec);
%     p.addParameter('LineWidth' , 1.5, ispositive);
% 
%     p.KeepUnmatched = true;
%     p.parse(varargin{:});
%     res = p.Results;
% 
%     parent = drawing.findCurrentGeomatplot(res.Parent); res = rmfield(res,'Parent'); % creates or converts if necesseray
%     if isempty(res.Label); res.Label = parent.getNextSmallLabel; end
%     label = res.Label; res = rmfield(res,'Label');
%     labels = drawing.getHandlesOfLabels(parent,res.Labels);
%     [~,LineStyle, Marker, Color] = drawing.matchLineSpec(res.LineSpec);
%     
%     if ~isempty(LineStyle); res.LineStyle = LineStyle; end
%     if ~isempty(Marker); res.Marker = Marker; end
%     if ~isempty(Color); res.Color = Color; else; res.Color='k'; end
% 
%     res = rmfield(res,{'Labels','LineSpec'});
%     
%     args = [namedargs2cell(res) namedargs2cell(p.Unmatched)];
% end