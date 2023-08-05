function h = PerpendicularBisector(varargin)
% PerpendicularBisector  draws a perpendicular bisector.
%   PerpendicularBisector({A,B}) draws the perpendicular bisector line seperating A and B points.
%
%   PerpendicularBisector(label,{A,B})  provides a label for the line. The label is not drawn.
%
%   PerpendicularBisector(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one.
%
%   PerpendicularBisector(___,linespec)  specifies line style, the default is 'k-'.
%
%   PerpendicularBisector(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = PerpendicularBisector(___)  returns the created handle.

    [parent,label,inputs,args] = dlines.parse_inputs(varargin);

    h_ = dlines(parent,label,inputs,@perpendicular_bisector,args);

    if nargout == 1; h = h_; end
    
end

function v = perpendicular_bisector(a,b)
    a = a.value; b = b.value;
    v = ((a-b)*[0 1; -1 0].*(0.5-[-1e8;-1e4;0;1;1e4;1e8]))+(a+b)*0.5;
end