function h = AngleBisector(varargin)
% ANGLEBISECTOR  draws an angular bisector.
%   ANGLEBISECTOR({A,B,C}) draws the angular bisector line through B and between A and C.
%
%   ANGLEBISECTOR(label,{A,B,C})  provides a label for the line. The labe is not drawn.
%
%   ANGLEBISECTOR(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one.
%
%   ANGLEBISECTOR(___,linespec)  specifies line style, the default is 'k-'.
%
%   ANGLEBISECTOR(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = ANGLEBISECTOR(___)  returns the created handle.

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