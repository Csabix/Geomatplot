function line = drawLine(varargin)
    if mod(nargin,2) == 0
        plt = cplt;
    else
        plt = varargin{1};
        varargin = varargin(2:end);
    end

    defaultColor = [0 0 0 1];
    defaultLabel = "";
    defaultLabelAlpha = 1.0;
    defaultVisible = true;
    defaultLabelTextColor = [0,0,0];
    defaultMarkerSize = 20.0;

    p = inputParser;

    addRequired(p,"X");
    addRequired(p,"Y");
    addParameter(p,"Color",defaultColor);
    addParameter(p,"Label", defaultLabel);
    addParameter(p,"LabelAlpha",defaultLabelAlpha);
    addParameter(p,"Visible",defaultVisible);
    addParameter(p,"LabelTextColor",defaultLabelTextColor);
    addParameter(p,"LineWidth",defaultMarkerSize);


    parse(p,varargin{:});
    
    color = p.Results.Color;
    if ~isnumeric(color)
        switch color
            case 'r'
                color = [1 0 0 1];
            case 'g'
                color = [0 1 0 1];
            case 'b'
                color = [0 0 1 1];
            case 'c'
                color = [0 1 1 1];
            case 'm'
                color = [1 0 1 1];
            case 'y'
                color = [1 1 0 1];
            case 'k'
                color = [0 0 0 1];
            case 'w'
                color = [1 1 1 1];
        end
    end

    jLine = GeomatPlot.gLine(single(p.Results.X),single(p.Results.Y),color);
    plt.addDrawable(jLine);
    line = LineH(jLine,plt);
end

