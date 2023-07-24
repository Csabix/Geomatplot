function h = Line(varargin)
% TODO write help

    [parent,label,inputs,linespec,args] = parse_line_inputs(varargin{:});
    drawing.mustBeOfLength(inputs,2);
    callback = @(a,b) a+(b-a).*[-1e8;-1e4;0;1;1e4;1e8];
    h_ = dlines(parent,label,inputs,linespec,callback,args);

    if nargout == 1; h = h_; end
    
end
