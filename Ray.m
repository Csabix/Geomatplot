function h = Ray(varargin)
% TODO write help

    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin{:});
    drawing.mustBeOfLength(inputs,2);
    callback = @(a,b) a.value+(b.value-a.value).*[0;1;1e4;1e8];
    h_ = dlines(parent,label,inputs,linespec,callback,args);

    if nargout == 1; h = h_; end

end