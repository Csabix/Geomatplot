function h = AngleBisector(varargin)
% TODO write help

    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin{:});

    kernel = [-1e8;-1e4;0;1;1e4;1e8];
    callback = @(a,b,c) b+((a-b)/sqrt(dot(a-b,a-b)) + (c-b)/sqrt(dot(c-b,c-b))).*kernel;
    h_ = dlines(parent,label,inputs,linespec,callback,args);

    if nargout == 1; h = h_; end
    
end
