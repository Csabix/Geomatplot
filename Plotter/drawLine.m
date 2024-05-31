function line = drawLine(varargin)
    if mod(nargin,2) == 0
        plt = cplt;
    else
        plt = varargin{1};
        varargin = varargin(2:end);
    end

    defaultColor = [0 0 0];
    defaultWidth = 1;
    defaultLineStyle = '-';

    p = inputParser;
    p.KeepUnmatched = true;

    addRequired(p,"X");
    addRequired(p,"Y");
    addParameter(p,"Color",defaultColor);
    addParameter(p,"LineStyle",defaultLineStyle)
    addParameter(p,"LineWidth",defaultWidth);

    parse(p,varargin{:});

    color = p.Results.Color;
    if ~isnumeric(color)
        color = parseColor(color);
    end

    dashed = false;
    if p.Results.LineStyle == "--"
        dashed = true;
    end

    x = p.Results.X;
    y = p.Results.Y;
    if(numel(x) < 2)
        x = [0;0];
    end

    if(numel(y) < 2)
        y = [0;0];
    end

    jLine = GeomatPlot.Draw.gLine(x,y,color,p.Results.LineWidth * 5,dashed);
    line = LineH(jLine,plt);
end