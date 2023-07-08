function h = Segment(varargin)
    [parent,label,labels,args] = parse_line_inputs(2,varargin{:});
    callback = @(a,b) a+(b-a).*[0;1];
    h = dlines(parent,label,labels,callback,args);
end