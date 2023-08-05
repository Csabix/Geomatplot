function h = Vector(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label, varargin] = parent.extractLabel(varargin,'small');
    [inputs,varargin] = parent.extractInputs(varargin,2,2);
    [linespec,args] = parse_(varargin{:});
    if drawing.isInputPatternMatching(inputs,{'point_base','point_base'})
        callback = @(a,b) b.value-a.value;
        h_ = dvector(parent,label,inputs,callback,inputs{1},linespec,args);
%     elseif drawing.isInputPatternMatching(inputs,{'point_base','dvector'})
%         h = inputs{2};
%         h.pt = inputs{1};
    else
        throw(MException('Vector:invalidInputPattern','Cannot create vector for these input types.'));
    end

    if nargout >=1; h=h_; end
end

function [linespec,args] = parse_(linespec,args)
    arguments
        linespec             (1,:) char   {drawing.mustBeLineSpec}                  = 'k'
        args.MaxHeadSize     (1,1) double {mustBePositive}
        args.LineWidth       (1,1) double {mustBePositive}
    end
end

