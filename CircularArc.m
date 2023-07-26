
function [h,c,r,alpha,beta] = CircularArc(varargin)
% TODO write help

    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin{:});

    if drawing.isInputPatternMatching(inputs,{'point_base','point_base','point_base'})
    % (center, starting_point, third_point) -- third_point sets the arc angle
        c_ = inputs{1};
        r_ = Distance(parent,inputs(1:2));
        alpha_ = dscalar(parent, parent.getNextLabel('small'), inputs(1:2), @base_angle);
        beta_ = dscalar(parent, parent.getNextLabel('small'), inputs, @angle_between);
    elseif drawing.isInputPatternMatching(inputs,{'point_base','point_base','dscalar'})
    % (center, starting_point, angle)
        c_ = inputs{1};
        r_ = Distance(parent,inputs(1:2));
        alpha_ = dscalar(parent, parent.getNextLabel('small'), inputs(1:2), @base_angle);
        beta_ = inputs{3};
    else
        eidType = 'CircularArc:invalidInputPattern';
        msgType = 'Unsupported input label types or unknown overload.';
        throw(MException(eidType,msgType));
    end
    
    h_ = dcurve(parent,label,{c_,r_,alpha_,beta_},linespec,@circ_arc,args);

    if nargout >= 1; h = h_; end
    if nargout >= 2; c = c_; end
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




