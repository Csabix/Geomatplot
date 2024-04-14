function h = AngleBisector(varargin)
% AngleBisector  draws an angular bisector.
%   AngleBisector(A,B,C) draws the angular bisector line through B and between A and C. Outer
%       bisector is not drawn. To draw both, use AngleBisector({A,B,C,D}) version.
%
%   AngleBisector(A,B,C,D) draws the two angular bisectors of the lines AB and CD.
%
%   AngleBisector(label,A,B,C)  provides a label for the line. The label is not drawn.
%
%   AngleBisector(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one.
%
%   AngleBisector(___,linespec)  specifies line style, the default is 'k-'.
%
%   AngleBisector(___,linespec,linewidth) also specifies the line thichness.
%
%   AngleBisector(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = AngleBisector(___)  returns the created handle.
%
%   See also POINT, LINE, SEGMENT, RAY, PerpendicularBisector, INTERSECT

    [parent,label,inputs,args] = dlines.parse_inputs(varargin,'angbi',3,4);
    if drawing.isInputPatternMatching(inputs,{'point_base','point_base','point_base'})
        callback = @angle_bisector3;
    elseif drawing.isInputPatternMatching(inputs,{'point_base','point_base','point_base','point_base'})
        callback = @angle_bisector4;
    else
        throw(MException('AngleBisector:invalidInputPattern','Unknown overload.'));
    end
    args.SizeOverride = 6;
    h_ = dlines(parent,label,inputs,callback,args);

    if nargout == 1; h = h_; end
    
end

function v = angle_bisector3(a,b,c)
    a = a.value; b = b.value; c = c.value;
    ab = a-b; cb = c-b;
    v = b+(ab/sqrt(dot(ab,ab)) + cb/sqrt(dot(cb,cb))).*[-1e8;-1e4;0;1;1e4;1e8];
end

function vv = angle_bisector4(a1,a2,b1,b2)
    a1 = a1.value; a2 = a2.value; b1 = b1.value; b2 = b2.value;
    na = (a2-a1)*[0 1;-1 0];
    nb = (b2-b1)*[0 1;-1 0];
    p0 = ([na;nb]\[na*a1';nb*b1'])';
    v1 = na/sqrt(na*na')+nb/sqrt(nb*nb'); %v2 = v1*[0 1;-1 0];
    vv = p0 + [v1.*[-1e8;-1e4;0;1;1e4;1e8];NaN NaN; v1*[0 1;-1 0].*[-1e8;-1e4;0;1;1e4;1e8]];
end

