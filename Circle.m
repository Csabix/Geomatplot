
function [h,c,r] = Circle(varargin)
% TODO write help

    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin{:});

    if drawing.isInputPatternMatching(inputs,{'point_base','point_base','point_base'})
        xargs.MarkerSize = 5; xargs.Color = 'k';
        c_ = dpoint(parent,parent.getNextLabel('small'),inputs,@eqidistpoint,xargs);
        r_ = Distance(parent,{c_,inputs{1}});
    elseif drawing.isInputPatternMatching(inputs,{'point_base','dscalar'})
        c_ = inputs{1}; r_ = inputs{2};
    elseif drawing.isInputPatternMatching(inputs,{'dscalar','point_base'})
        c_ = inputs{2}; r_ = inputs{1};
    elseif drawing.isInputPatternMatching(inputs,{'point_base','point_base'}) || drawing.isInputPatternMatching(inputs,{'point_base','dpointlineseq'})
        c_ = inputs{1};
        r_ = Distance(parent,{c_,inputs{2}});
    else
        error 'Unsupported input label types or unknown overload.'
    end

    h_ = dcircle(parent,label,c_,r_,linespec,args);

    if nargout >= 1; h = h_; end
    if nargout >= 2; c = c_; end
    if nargout >= 3; r = r_; end
    
end

function o = eqidistpoint(a,b,c)
    % https://math.stackexchange.com/questions/213658/get-the-equation-of-a-circle-when-given-3-points/1144546
    a = a.value; b = b.value; c = c.value;
    a = complex(a(1),a(2));
    b = complex(b(1),b(2));
    c = complex(c(1),c(2));
    w = (c-a)/(b-a);
    if abs(imag(w)) <= 1e-15
        throw([]);
    else
        o = (b-a)*(w - w*w')/(2*1i*imag(w)) + a;
        o = [real(o) imag(o)];
    end
end

% mpoint dsegment dpoint
% dsegment mpoint 