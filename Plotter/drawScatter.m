function scatter = drawScatter(varargin)
    if mod(nargin,2) == 0
        plt = cplt;
    else
        plt = varargin{1};
        varargin = varargin(2:end);
    
    end
    defaultColor = [0 0.44 0.74];
    defaultPosition = [0 0];
    defaultMarkerSize = 15;
    defaultVisible = true;

    p = inputParser;
    p.KeepUnmatched = true;

    addParameter(p,"Position",defaultPosition);
    addParameter(p,"MarkerColor",defaultColor);
    addParameter(p,"MarkerSize",defaultMarkerSize);
    addParameter(p,"Visible",defaultVisible);

    parse(p,varargin{:});

    color = p.Results.MarkerColor;
    if ~isnumeric(color)
        color = parseColor(color);
    end

    scatter = ScatterH(p.Results.Position,plt,color,p.Results.MarkerSize,p.Results.Visible);

end

