
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
    elseif drawing.isInputPatternMatching(inputs,{'point_base','point_base'}) || ...
           drawing.isInputPatternMatching(inputs,{'point_base','dpointlineseq'}) || ...
           drawing.isInputPatternMatching(inputs,{'point_base','mpolygon'})
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
    a = a.value; b = b.value; c = c.value;
    n = a-b; m = b-c;
    o = 0.5*[(a+b)*n' (b+c)*m']/[n;m]';
end




