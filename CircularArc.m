function [h,angle,O,r] = CircularArc(varargin)
% CircularArc  draws an circular arc
%   CircularArc(O,B,C) draws a circluar arc around O starting from B until it meets the OC line in
%       anticlockwise direction.
%
%   CircularArc(O,B,alpha) draws a circluar arc around O starting from B with angle alpha in
%       anticlockwise direction.
%
%   CircularArc(label,{___})  provides a label for the circle. The label is not drawn.
%
%   CircularArc(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. Thus must preceed the label argument if that is given also.
%
%   CircularArc(___,linespec)  specifies line style, the default is 'k-'.
%
%   CircularArc(___,linespec,linewidth) also specifies the line thichness.
%
%   CircularArc(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = CircularArc(___)  returns the created handle for the arc.
%
%   [h,O] = CircularArc(___)  also returns the handle of the center point O.
%
%   [h,O,r] = CircularArc(___)  returns the radius handle r which is a dependent Geomaplot scalar.
%
%   [h,O,r,alpha] = CircularArc(___)  returns the angle of the arc in radians.
%
%   [h,O,r,alpha,beta] = CircularArc(___)  returns the start angle compared to the x axis.
%
%   See also Circle, CircumcircularArc, DISTANCE, SEGMENT, INTERSECT

    [parent,label,inputs,args] = dlines.parse_inputs(varargin,'carc',3,3);

    if drawing.isInputPatternMatching(inputs,{'point_base','point_base','point_base'})
    % (center, starting_point, third_point) -- third_point sets the arc angle
        angle = dscalar(parent, parent.getNextLabel('small'), inputs, @angle_between);
    elseif drawing.isInputPatternMatching(inputs,{'point_base','point_base','dscalar'})
    % (center, starting_point, angle)
        angle = inputs{3};
    else
        throw(MException('CircularArc:invalidInputPattern','Unsupported input label types or unknown overload.'));
    end
    O = inputs{1};
    r = Distance(parent,inputs(1:2));
    h = dcurve(parent,label,{O,r,inputs{2},angle},@circ_arc_fused,args);
    
end

function o = polar(A) % deviation from the x-axis [-pi,pi]
    o = atan2(A(2),A(1));
end

function v = circ_arc_fused(t,O_,r,A,angle)
    O = O_.value;
    t = polar(A.value-O) + angle.value*t;
    v = O + r.value*[cos(t) sin(t)];
end

% angle between three points [0,2pi]
function o = angle_between(a,b,c)
    e = c.value - a.value;
    f = b.value - a.value;
    o = atan2(e(2),e(1)) - atan2(f(2),f(1));
    if o < 0; o = o + 2*pi; end
end




