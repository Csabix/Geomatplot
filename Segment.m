function h = Segment(varargin)
% SEGMENT  draws a straight segment between two Geomatplot points.
%   SEGMENT({A,B}) draws a line segment between point A and point B.
%
%   SEGMENT(label,{A,B})  provides a label for the line. The label is not drawn.
%
%   SEGMENT(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one.
%
%   SEGMENT(___,linespec)  specifies line style, the default is 'k-'.
%
%   SEGMENT(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = SEGMENT(___)  returns the created handle.
%
%   See also POINT, LINE, RAY, PerpendicularBisector, AngleBisector, INTERSECT

    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin);
    callback = @(a,b) a.value+(b.value-a.value).*[0;1];
    h_ = dlines(parent,label,inputs,linespec,callback,args);

    if nargout == 1; h = h_; end
    
end
