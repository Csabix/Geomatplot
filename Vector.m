function h = Vector(varargin)
    [parent,label,inputs,linespec,args] = parse(varargin{:});

    h_ = dvector(parent,label,inputs,@(a,b) b.value-a.value,inputs{1},linespec,args);
    if nargout >=1; h=h_; end
end

function [parent,label,inputs,linespec,args] = parse(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label,varargin] = parent.extractLabel(varargin,'small');
    [parent,label,inputs,linespec,args] = parse_(parent,label,varargin{:});
    inputs = parent.getHandlesOfLabels(inputs);
end

function [parent,label,inputs,linespec,args] = parse_(parent,label,inputs,linespec,args)
    arguments
        parent               (1,1) Geomatplot
        label                (1,:) char   {mustBeValidVariableName}
        inputs               (1,2) cell   {drawing.mustBeInputList(inputs,parent)}
        linespec             (1,:) char   {drawing.mustBeLineSpec}                  = 'k'
        args.MaxHeadSize     (1,1) double {mustBePositive}
        args.LineWidth       (1,1) double {mustBePositive}
    end
end

