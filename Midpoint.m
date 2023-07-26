function h = Midpoint(varargin)
% Midpoint  creates a midpoint or centroid between two points or more points
%
%   Midpoint({A,B}) creates a dependent Geomatplot point that is a midpoint between A and B points.
%
%   Midpoint({A,B,C,...}) creates the centroid point of any number of points or polygons or curves.
%       For curves, it uses its automatic polygonization.
%
%   Midpoint(label,___)  provides a label for the point.
%
%   Midpoint(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. Thus must preceed the label argument if that is given also.
%
%   Midpoint(___,color)  specifies the color of the point and its label, the default is 'b'. This may
%       be a colorname or a three element vector.
%
%   Midpoint(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = Midpoint(___)  returns the created handle.
%
%   See also POINT, SEGMENT, CIRCLE

    [parent,label,inputs,args] = parse(varargin{:});
    %callback = @(varargin) mean(vertcat(varargin{:}));
    for i = 1:length(inputs)
        l = inputs{i};
        if isa(l,'dcurve') || isa(l,'dimage') || isa(l,'dscalar')
            eidType = 'Midpoint:invalidInput';
            msgType = 'The input drawing cannot be of this type.';
            throw(MException(eidType,msgType));
        end
    end
    h = dpoint(parent,label,inputs,@callback,args);
    
end

function v = callback(varargin)
    x = varargin{1}.value;
    n = size(x,1);
    v = mean(x,1);
    for j=2:nargin
        x = varargin{j}.value;
        n1 = size(x,1);
        v = v*n/(n+n1) + mean(x,1)*n1/(n+n1);
        n = n + n1;
    end
end

function [parent,label,inputs,args] = parse(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'capital');
    [parent,label,inputs,args] = parse_(parent,label,varargin{:});
    inputs = parent.getHandlesOfLabels(inputs);
end

function [parent,label,inputs,args] = parse_(parent,label,inputs,color,args)
    arguments
        parent          (1,1) Geomatplot
        label           (1,:) char      {mustBeValidVariableName}
        inputs          (1,:) cell      {drawing.mustBeInputList(inputs,parent)}
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

