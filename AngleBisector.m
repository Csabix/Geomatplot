function h = AngleBisector(varargin)
    kernel = [-1e8;-1e4;0;1;1e4;1e8];
    [parent,label,labels,args] = parse_line_inputs(3,varargin{:});
    callback = @(a,b,c) b+((a-b)/sqrt(dot(a-b,a-b)) + (c-b)/sqrt(dot(c-b,c-b))).*kernel;
    h = dlines(parent,label,labels,callback,args);
end