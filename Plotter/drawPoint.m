function point = drawPoint(varargin)
    if mod(nargin,2) == 0
        plt = cplt;
    else
        plt = varargin{1};
        varargin = varargin(2:end);
    end
    defaultColor = [0 0.44 0.74];
    defaultPosition = [];
    defaultMovable = true;
    defaultMarkerSize = 4;

    p = inputParser;
    p.KeepUnmatched = true;

    addParameter(p,"Position",defaultPosition);
    addParameter(p,"Color",defaultColor);
    addParameter(p,"Movable",defaultMovable);
    addParameter(p,"MarkerSize",defaultMarkerSize);

    parse(p,varargin{:});

    position = p.Results.Position;
    if isempty(position)
        position = plt.getInput(@(x)x.isButton(1));
    end

    color = p.Results.Color;
    if ~isnumeric(color)
        color = parseColor(color);
    end
    
    %jPoint = GeomatPlot.Draw.gPoint(position(1),position(2), color, p.Results.MarkerSize * 3,0,p.Results.Movable);
    %plt.addDrawable(jPoint);
    %point = PointH(jPoint,plt);
    point = PointH(plt,position,color,p.Results.MarkerSize * 3,0,p.Results.Movable);
end

