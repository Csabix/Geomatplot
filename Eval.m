function val = Eval(varargin)
% Eval  creates a drawing form an expression
%   Eval(expr) creates the drawing with an automatic label.
%
%   Eval(label,___) provides the label for the new object.
%
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);
    [label,varargin] = parent.extractLabel(varargin,'expr');
    assert(length(varargin)==1 && isa(varargin{1},'expression_base') && varargin{1}.parent == parent,'invalid input');
    val = varargin{1}.eval(label);
end