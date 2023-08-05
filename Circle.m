function [h,O,r] = Circle(varargin)
% Circle  draws a circle
%   Circle({A,B,C}) draws a circumscribed circle going throuh Geomatplot points A, B, and C.
%
%   Circle({A,B}) draws a circle around point A extending to point B.
%
%   Circle({A,r}) draws a circle around point A with radius r which is a Geomaplot scalar value.
%
%   Circle({A,c}) draws a circle around point A  touching the Geomatplot drawing c. Equivalent to
%       the call Circle({A,Distance({A,c})).
%
%   Circle(label,{___})  provides a label for the circle which is not drawn.
%
%   Circle(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. Thus must preceed the label argument if that is given also.
%
%   Circle(___,linespec)  specifies line style, the default is 'k-'.
%
%   Circle(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = Circle(___)  returns the created handle for the circle.
%
%   [h,O] = Circle(___)  also returns the handle of the center point C.
%
%   [h,O,r] = Circle(___)  returns the radius handle r which is a dependent Geomaplot scalar.
%
%   See also CirclularArc, POINT, DISTANCE, SEGMENT, INTERSECT

    [parent,label,inputs,args] = dlines.parse_inputs(varargin,'small',2,3);

    if drawing.isInputPatternMatching(inputs,{'point_base','point_base','point_base'})
        c_ = dpoint(parent,parent.getNextLabel('small'),inputs,@equidistpoint);
        r_ = Distance(parent,{c_,inputs{1}});
    elseif drawing.isInputPatternMatching(inputs,{'point_base','dscalar'})
        c_ = inputs{1}; r_ = inputs{2};
    elseif drawing.isInputPatternMatching(inputs,{'point_base',{'point_base','dpointlineseq','mpolygon'}})
        c_ = inputs{1};
        r_ = Distance(parent,{c_,inputs{2}});
    else
        throw(MException('CircularArc:invalidInputPattern','Unsupported input label types or unknown overload.'));
    end

    h_ = dcircle(parent,label,c_,r_,args);

    if nargout >= 1; h = h_; end
    if nargout >= 2; O = c_; end
    if nargout >= 3; r = r_; end
    
end

function o = equidistpoint(a,b,c)
    a = a.value; b = b.value; c = c.value;
    n = a-b; m = b-c;
    o = 0.5*[(a+b)*n' (b+c)*m']/[n;m]';
end




