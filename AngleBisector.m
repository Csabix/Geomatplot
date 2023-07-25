function h = AngleBisector(varargin)
% TODO write help

    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin{:});

    h_ = dlines(parent,label,inputs,linespec,@callback,args);

    if nargout == 1; h = h_; end
    
end

function v = callback(a,b,c)
    a = a.value; b = b.value; c = c.value;
    ab = a-b; cb = c-b;
    v = b+(ab/sqrt(dot(ab,ab)) + cb/sqrt(dot(cb,cb))).*[-1e8;-1e4;0;1;1e4;1e8];
end