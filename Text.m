function h = Text(varargin)

%% usage
% clf; g = Geomatplot;
% A = Point([1,1]);
% h = dtext(g,'asd',{A},@str,struct);
% 
% function [pos,text] = str(a)
%     pos = a.value;
%     text = ['   ' num2str(pos)];
% end
% Text(A,A) or Text([0 1],A)
% Text(A,'asd') or Text([0 1],'asd')
% Text({A},@str) %a.value is given instead
% Text(A, {B}, @(B) num2str(B)); or Text([0 1], {B}, @(B) num2str(B));


    % callback(a1,a2,...) -> [text,pos]

    % todocalllback
    [parent,label,inputs,args] = parse(varargin{:});
    
    h_ = dtext(parent,label,inputs,callback,args);
    
    if nargout == 1; h = h_; end

end

function [parent,label,inputs,args] = parse(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'small');
    % todo??
    [parent,label,inputs,args] = parse_(parent,label,varargin{:});
    inputs = parent.getHandlesOfLabels(inputs);
end

function [parent,label,inputs,args] = parse_(parent,label,inputs,color,args)
    arguments
        parent          (1,1) Geomatplot
        label           (1,:) char      {mustBeValidVariableName}
        inputs          (1,:) cell      {drawing.mustBeInputList(inputs,parent)}
        usercallback    (1,1) function_handle {}
        color                           {drawing.mustBeColor}               = 'k'
        args.MarkerSize (1,1) double    {mustBePositive}                    = 7
        args.LabelAlpha (1,1) double    {mustBeInRange(args.LabelAlpha,0,1)}= 0
        args.LabelTextColor             {drawing.mustBeColor}
        args.LineWidth  (1,1) double    {mustBePositive}
    end
    args.Label = label;
    args.Color = color;
    if ~isfield(args,'LabelTextColor'); args.LabelTextColor = color; end
end