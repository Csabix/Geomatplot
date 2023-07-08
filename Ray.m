function h = Ray(varargin)
    [parent,label,labels,args] = parse_line_inputs(2,varargin{:});
    callback = @(a,b) a+(b-a).*[0;1;1e4;1e8];
    h = dlines(parent,label,labels,callback,args);
end