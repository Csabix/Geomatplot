function pointCloud = Scatter(varargin)
    if mod(nargin,2) == 0
        plt = cplt;
    else
        plt = varargin(1);
        varargin = varargin(2:end);
    
    end
    defaultColor = [0 0.4470 0.7410];
    defaultPosition = [0 0];
    defaultMarkerSize = 15;

    p = inputParser;
    p.KeepUnmatched = true;

    addParameter(p,"Position",defaultPosition);
    addParameter(p,"MarkerColor",defaultColor);
    addParameter(p,"MarkerSize",defaultMarkerSize);

    parse(p,varargin{:});

    color = p.Results.MarkerColor;
    if ~isnumeric(color)
        color = parseColor(color);
    end

    pointCloud = PointCloudH(p.Results.Position,plt,color,p.Results.MarkerSize,true)

end

