
function h = Circle(varargin)
% TODO write help

    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin{:});

    if drawing.isInputPatternMatching(inputs,{'point_base','point_base'})
        callback = @circ_center_and_point;
    elseif drawing.isInputPatternMatching(inputs,{'point_base','point_base','point_base'})
        callback = @circ_3_points;
    else
        error 'Unsupported input label types or unknown overload.'
    end

    h_ = dcurve(parent,label,inputs,linespec,callback,args);

    if nargout == 1; h = h_; end
    
end

function v = circ_center_and_point(t,c,p)
    d = p-c; t = 2*pi*t;
    v = c+sqrt(d(1)*d(1)+d(2)*d(2))*[cos(t) sin(t)];
end

function v = circ_3_points(t,a0,b,c)
    % https://math.stackexchange.com/questions/213658/get-the-equation-of-a-circle-when-given-3-points/1144546
    a = complex(a0(1),a0(2));
    b = complex(b(1),b(2));
    c = complex(c(1),c(2));
    w = (c-a)/(b-a);
    if abs(imag(w)) <= 1e-15
        v=[];
    else
        o = (b-a)*(w - w*w')/(2*1i*imag(w)) + a;
        v = circ_center_and_point(t,[real(o) imag(o)],a0);
    end
end

% mpoint dsegment dpoint
% dsegment mpoint 