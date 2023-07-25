function h = PerpendicularBisector(varargin)
% TODO write help

    [parent,label,inputs,linespec,args] = dlines.parse_inputs(varargin{:});
    drawing.mustBeOfLength(inputs,2);

    h_ = dlines(parent,label,inputs,linespec,@callback,args);

    if nargout == 1; h = h_; end
    
end

function v = callback(a,b)
    a = a.value; b = b.value;
    v = ((a-b)*[0 1; -1 0].*(0.5-[-1e8;-1e4;0;1;1e4;1e8]))+(a+b)*0.5;
end