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

    [parent,label,inputs,args] = dlines.parse_inputs(varargin,'small',3,3);
    if drawing.isInputPatternMatching(inputs,{'point_base','point_base','point_base'})
        % do nothing
    else
        throw(MException('AngleBisector:invalidInputPattern','Unknown overload.'));
    end

    h_ = dlines(parent,label,inputs,@angle_bisector,args);

    if nargout == 1; h = h_; end
    
end

function v = angle_bisector(a,b,c)
    a = a.value; b = b.value; c = c.value;
    ab = a-b; cb = c-b;
    v = b+(ab/sqrt(dot(ab,ab)) + cb/sqrt(dot(cb,cb))).*[-1e8;-1e4;0;1;1e4;1e8];
end