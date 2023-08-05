function h = Vector(varargin)
    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);    
    [label, varargin] = parent.extractLabel(varargin,'small');
    [inputs,varargin] = parent.extractInputs(varargin,2,2);
    args = parse_(varargin{:});
    if drawing.isInputPatternMatching(inputs,{'point_base','point_base'})
        callback = @(a,b) b.value-a.value;
        h_ = dvector(parent,label,inputs,callback,inputs{1},args);
%     elseif drawing.isInputPatternMatching(inputs,{'point_base','dvector'})
%         h = inputs{2};
%         h.pt = inputs{1};
    else
        throw(MException('Vector:invalidInputPattern','Cannot create vector for these input types.'));
    end

    if nargout >=1; h=h_; end
end

function params = parse_(linespec,linewidth,params)
    arguments
        linespec           (1,:) char   {drawing.mustBeLineSpec} = 'k'
        linewidth          (1,1) double {mustBePositive}         =  1
        params.MaxHeadSize (1,1) double {mustBePositive}
        params.LineWidth   (1,1) double {mustBePositive}
        params.LineStyle (1,:) char
        params.Marker    (1,:) char
        params.Color                    {drawing.mustBeColor}
    end
    if ~isfield(params,'LineWidth'); params.LineWidth = linewidth; end
    params = dlines.applyLineSpec(params,linespec);
end

