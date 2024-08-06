function [h,p] = ParallelLine(varargin)
% ParallelLine  draws a parallel line.
%   ParallelLine(A,B,C) draws a parallel line through A to BC
%
%   ParallelLine(B,C,d) draws a translated parallel line to BC at signed distance d
%
%   ParallelLine(label,___)  provides a label for the line. The label is not drawn.
%
%   ParallelLine(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one.
%
%   ParallelLine(___,linespec)  specifies line style, the default is 'k-'.
%
%   ParallelLine(___,linespec,linewidth) also specifies the line thichness.
%
%   ParallelLine(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = ParallelLine(___)  returns the created handle.

    eidType = 'Perpendicular:invalidInputPattern';
    msgType = 'Cannot create perpendicular line for these input types';

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);   
    [label, varargin] = parent.extractLabel(varargin,'perpln');
    [inputs,varargin] = parent.extractInputs(varargin,2,3);

    if drawing.isInputPatternMatching(inputs,{'point_base','point_base','point_base'})
        args= dlines.parse_inputs_(varargin{:});
        h_ = dlines(parent,label,inputs,@paraline2segment,args);
    elseif drawing.isInputPatternMatching(inputs,{'point_base','point_base','dscalar'})
        args= dlines.parse_inputs_(varargin{:});
        h_ = dlines(parent,label,inputs,@paralinewithdist,args);
    % elseif drawing.isInputPatternMatching(inputs,{'point_base','drawing'})
    %     p_ = ClosestPoint(parent,inputs{:},'LabelVisible','off','MarkerSize',5);
    %     h_ = Line(parent,label,{inputs{1},p_},varargin{:});
    %   ParallelLine(A,a) draws a perpendicular line from A to any curve or lines by drawing a
    %       line to the closest point. Note that expected behaviour may differ.
    else
       throw(MException(eidType,msgType));
    end

    if nargout >= 1; h = h_; end
    if nargout >= 2; p = p_; end
end

function v=paralinewithdist(a,b,d)
    dir = (b.value-a.value);
    n = dir*[0 1;-1 0]/sqrt(dir*dir.');
    v = a.value + d.value*n + dir.*[-1e8;-1e4;0;1;1e4;1e8];
end

function v=paraline2segment(p,a,b)
    v = p.value + (b.value-a.value).*[-1e8;-1e4;0;1;1e4;1e8];
end