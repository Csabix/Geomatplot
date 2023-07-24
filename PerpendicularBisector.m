function h = PerpendicularBisector(varargin)
% TODO write help

    [parent,label,inputs,linespec,args] = parse_line_inputs(varargin{:});
    drawing.mustBeOfLength(inputs,2);
    callback = @(a,b) ((a-b)*0.5+(b-a).*[-1e8;-1e4;0;1;1e4;1e8])*[0 1; -1 0]+(a+b)*0.5;
    h_ = dlines(parent,label,inputs,linespec,callback,args);

    if nargout == 1; h = h_; end
    
end

% function h = PerpendicularBisector(varargin)
%     [parent,label,labels,args] = parse_line_inputs(2,varargin{:});
%     callback = @(a,b) ((a-b)*0.5+(b-a).*[-1e8;-1e4;0;1;1e4;1e8])*[0 1; -1 0]+(a+b)*0.5;
%     h = dlines(parent,label,labels,callback,args);
% end