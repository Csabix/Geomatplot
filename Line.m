function h = Line(varargin)
% LINE  draws a line between two Geomatplot points.
%   LINE({A,B}) draws a line between point A and point B extending past both points.
%
%   LINE(label,{A,B})  provides a label for the line. The label is not drawn.
%
%   LINE(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one.
%
%   LINE(___,linespec)  specifies line style, the default is 'k-'.
%
%   LINE(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = LINE(___)  returns the created handle.
%
%   See also POINT, SEGMENT, RAY, PerpendicularBisector, AngleBisector, INTERSECT

    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin);
    callback = @(a,b) a.value+(b.value-a.value).*[-1e8;-1e4;0;1;1e4;1e8];
    h_ = dlines(parent,label,inputs,linespec,callback,args);

    if nargout == 1; h = h_; end
    
end
