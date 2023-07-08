function Curve(callback,varargin)
    [parent,label,labels,args] = parse_line_inputs(1:10,varargin{:}); % todo any number of inputs
    h = dcurve(parent,label,labels,callback,args);
end