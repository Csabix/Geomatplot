function [h,O,r,alpha,beta] = CircularArc(varargin)
% CircularArc  draws an circular arc
%   CircularArc({O,B,C}) draws a circluar arc around A starting from B until it meets the AC line in
%       anticlockwise direction.
%
%   CircularArc({O,B,alpha}) draws a circluar arc around A starting from B with angle alpha in
%       anticlockwise direction.
%
%   CircularArc(label,{___})  provides a label for the circle. The label is not drawn.
%
%   CircularArc(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. Thus must preceed the label argument if that is given also.
%
%   CircularArc(___,linespec)  specifies line style, the default is 'k-'.
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
%   See also Circle, POINT, DISTANCE, SEGMENT, INTERSECT

    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin,'small',3,3);

    if drawing.isInputPatternMatching(inputs,{'point_base','point_base','point_base'})
    % (center, starting_point, third_point) -- third_point sets the arc angle
        c_ = inputs{1};
        r_ = Distance(parent,inputs(1:2));
        beta_ = dscalar(parent, parent.getNextLabel('small'), inputs(1:2), @base_angle);
        alpha_ = dscalar(parent, parent.getNextLabel('small'), inputs, @angle_between);
    elseif drawing.isInputPatternMatching(inputs,{'point_base','point_base','dscalar'})
    % (center, starting_point, angle)
        c_ = inputs{1};
        r_ = Distance(parent,inputs(1:2));
        beta_ = dscalar(parent, parent.getNextLabel('small'), inputs(1:2), @base_angle);
        alpha_ = inputs{3};
    else
        throw(MException('CircularArc:invalidInputPattern','Unsupported input label types or unknown overload.'));
    end
    
    h_ = dcurve(parent,label,{c_,r_,beta_,alpha_},linespec,@circ_arc,args);

    if nargout >= 1; h = h_; end
    if nargout >= 2; O = c_; end
    if nargout >= 3; r = r_; end
    if nargout >= 4; alpha = alpha_; end
    if nargout >= 5; beta = beta_; end
    
end

function v = circ_arc(t,c,r,a,b)
    t = a.value + b.value*t;
    v = c.value + r.value*[cos(t) sin(t)];
end

% deviation of b-a from the x-axis [-pi,pi]
function o = base_angle(a,b)
    e = b.value - a.value;
    o = atan2(e(2),e(1));
end

% angle between three points [0,2pi]
function o = angle_between(a,b,c)
    e = c.value - a.value;
    f = b.value - a.value;
    o = atan2(e(2),e(1)) - atan2(f(2),f(1));
    if o < 0; o = o + 2*pi; end
end




