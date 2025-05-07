function [h,angle,O,r] = CircumcircularArc(varargin)
% CircumcircularArc  draws an circular arc
%   CircumcircularArc(A,B,C)  draws a circluar arc around A going through B until it ends up in C.
%
%   CircumcircularArc(label,{___})  provides a label for the circle. The label is not drawn.
%
%   CircumcircularArc(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. Thus must preceed the label argument if that is given also.
%
%   CircumcircularArc(___,linespec)  specifies line style, the default is 'k-'.
%
%   CircumcircularArc(___,linespec,linewidth)  also specifies the line thichness.
%
%   CircumcircularArc(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   [h,angle,O,r] = CircumcircularArc(___)  returns the created handle for
%       the arc, the oriented angle scalar value [-2pi,2pi], the center and
%       the radius, respectively.
%
%   See also Circle, CircularArc, DISTANCE, SEGMENT, INTERSECT

    [parent,label,inputs,args] = dlines.parse_inputs(varargin,'carc',3,3);

    if drawing.isInputPatternMatching(inputs,{'point_base','point_base','point_base'})
        O = dpoint(parent,parent.getNextLabel('center'),inputs,@equidistpoint);
        r = Distance(parent,{O,inputs{1}});
        angle = dscalar(parent,parent.getNextLabel('small'), [{O},inputs],@calc_angle);
    else
        throw(MException('CircularArc:invalidInputPattern','Unsupported input label types or unknown overload.'));
    end

    h = dcurve(parent,label,{O,r,inputs{1},angle},@circ_arc_fused,args);

end

% same as in Circle
function o = equidistpoint(a_,b_,c_)
    a = a_.value; b = b_.value; c = c_.value;
    n = a-b; m = b-c;
    o = 0.5*[(a+b)*n' (b+c)*m']/[n;m]';
end

function o = polar(A) % deviation from the x-axis [-pi,pi]
    o = atan2(A(2),A(1));
end

function v = circ_arc_fused(t,O_,r,A,angle)
    O = O_.value;
    t = polar(A.value-O) + angle.value*t;
    v = O + r.value*[cos(t) sin(t)];
end

function angle = calc_angle(O_,A,B,C)
    O = O_.value;
    a = polar(A.value-O);
    b = polar(B.value-O);
    c = polar(C.value-O);
    if mod(c-a,2*pi)<mod(b-a,2*pi)
        angle = -mod(2*pi-(c-a),2*pi);
    else
        angle = mod(c-a,2*pi);
    end
end