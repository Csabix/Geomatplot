function h = AngleBisector(varargin)
% AngleBisector  draws an angular bisector.
%   AngleBisector({A,B,C}) draws the angular bisector line through B and between A and C.
%
%   AngleBisector(label,{A,B,C})  provides a label for the line. The label is not drawn.
%
%   AngleBisector(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one.
%
%   AngleBisector(___,linespec)  specifies line style, the default is 'k-'.
%
%   AngleBisector(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = AngleBisector(___)  returns the created handle.
%
%   See also POINT, LINE, SEGMENT, RAY, PerpendicularBisector, INTERSECT

    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin{:});
    drawing.mustBeOfLength(inputs,3);

    h_ = dlines(parent,label,inputs,linespec,@callback,args);

    if nargout == 1; h = h_; end
    
end

function v = callback(a,b,c)
    a = a.value; b = b.value; c = c.value;
    ab = a-b; cb = c-b;
    v = b+(ab/sqrt(dot(ab,ab)) + cb/sqrt(dot(cb,cb))).*[-1e8;-1e4;0;1;1e4;1e8];
end