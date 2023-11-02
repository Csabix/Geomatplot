function [h,p] = PerpendicularLine(varargin)
% PerpendicularLine  draws a perpendicular line.
%   PerpendicularLine(A,B,C) draws a prependicular line from A to BC
%
%   PerpendicularLine(A,B) draws a prependicular line from A to AB
%
%   PerpendicularLine(A,a) draws a prependicular line from A to any curve or lines by drawing a
%       line to the closest point. Note that expected behaviour may differ.
%
%   PerpendicularLine(label,{...})  provides a label for the line. The label is not drawn.
%
%   PerpendicularLine(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one.
%
%   PerpendicularLine(___,linespec)  specifies line style, the default is 'k-'.
%
%   PerpendicularLine(___,linespec,linewidth) also specifies the line thichness.
%
%   PerpendicularLine(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = PerpendicularLine(___)  returns the created handle.

    eidType = 'Perpendicular:invalidInputPattern';
    msgType = 'Cannot create perpendicular line for these input types';

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);   
    [label, varargin] = parent.extractLabel(varargin,'perpln');
    [inputs,varargin] = parent.extractInputs(varargin,2,3);

    if drawing.isInputPatternMatching(inputs,{'point_base','point_base','point_base'})
        args= dlines.parse_inputs_(varargin{:});
        h_ = dlines(parent,label,inputs,@perpline2segment,args);
    elseif drawing.isInputPatternMatching(inputs,{'point_base','point_base'})
        args = dlines.parse_inputs_(varargin{:});
        h_ = dlines(parent,label,inputs,@perpline2point,args);
    elseif drawing.isInputPatternMatching(inputs,{'point_base','drawing'})
        p_ = ClosestPoint(parent,varargin{1},'LabelVisible','off','MarkerSize',5);
        h_ = Line(parent,label,{varargin{1}{1},p_},varargin{2:end});
    else
       throw(MException(eidType,msgType));
    end

    if nargout >= 1; h = h_; end
    if nargout >= 2; p = p_; end
end

function v=perpline2point(p,b)
    n = (b.value-p.value)*[0 1;-1 0];
    v = p.value + n.*[-1e8;-1e4;0;1;1e4;1e8];
end

function v=perpline2segment(p,a,b)
    n = (b.value-a.value)*[0 1;-1 0];
    v = p.value + n.*[-1e8;-1e4;0;1;1e4;1e8];
end