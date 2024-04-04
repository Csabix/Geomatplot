function h = Ray(varargin)
% RAY  draws a ray or half-line between two Geomatplot points.
%   RAY(A,B) draws a ray between point A and point B extending past point B.
%
%   RAY(label,A,B)  provides a label for the ray. The label is not drawn.
%
%   RAY(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one.
%
%   RAY(___,linespec)  specifies line style, the default is 'k-'.
%
%   RAY(___,linespec,linewidth) also specifies the line thichness.
%
%   RAY(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = RAY(___)  returns the created handle.
%
%   See also POINT, LINE, SEGMENT, PerpendicularBisector, AngleBisector, INTERSECT

    [parent,label,inputs,args] = dlines.parse_inputs(varargin,'ray');
    if drawing.isInputPatternMatching(inputs,{'point_base','point_base'})
        callback = @(a,b) a.value+(b.value-a.value).*[0;1;1e4;1e8];
    elseif drawing.isInputPatternMatching(inputs,{'point_base','dvector'})
        callback = @(a,b) a.value+b.value.*[0;1;1e4;1e8];
    else
        throw(MException('Ray:invalidInputPattern','Unknown overload.')); 
    end

    h_ = dlines(parent,label,inputs,callback,4,args);

    if nargout == 1; h = h_; end

end