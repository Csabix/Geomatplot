function point = drawPoint(varargin)
    if mod(nargin,2) == 0
        plt = cplt;
    else
        plt = varargin(1);
        varargin = varargin(2:end);
    end
    defaultColor = [0 0.4470 0.7410];
    defaultBorderColor = [];
    defaultPosition = [];
    defaultLabel = "";
    defaultMovable = true;
    defaultLabelAlpha = 1.0;
    defaultVisible = true;
    defaultLabelTextColor = [0,0,0];
    defaultMarkerSize = 20.0;

    p = inputParser;

    addParameter(p,"Position",defaultPosition);
    addParameter(p,"Color",defaultColor);
    addParameter(p,"Bcolor",defaultBorderColor);
    addParameter(p,"Movable",defaultMovable);
    addParameter(p,"Label", defaultLabel);
    addParameter(p,"LabelAlpha",defaultLabelAlpha);
    addParameter(p,"Visible",defaultVisible);
    addParameter(p,"LabelTextColor",defaultLabelTextColor);
    addParameter(p,"MarkerSize",defaultMarkerSize);

    parse(p,varargin{:});

    position = p.Results.Position;
    if isempty(position)
        position = plt.clickInput;
    end

    borderColor = p.Results.Bcolor;
    if isempty(borderColor)
        if p.Results.Movable
            borderColor = [0.9290 0.6940 0.1250];
        else
            borderColor = [0,0,0];
        end
    end
    
    color = p.Results.Color;
    if ~isnumeric(color)
        switch color
            case 'r'
                color = [1 0 0];
            case 'g'
                color = [0 1 0];
            case 'b'
                color = [0 0 1];
            case 'c'
                color = [0 1 1];
            case 'm'
                color = [1 0 1];
            case 'y'
                color = [1 1 0];
            case 'k'
                color = [0 0 0];
            case 'w'
                color = [1 1 1];
        end
    end
    jPoint = GeomatPlot.Draw.gPoint(single([position,color,borderColor]));
    plt.addDrawable(jPoint);
    point = PointH(jPoint,plt);
end

