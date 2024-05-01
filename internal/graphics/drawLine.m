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
    if p.Results.LineStyle ~= "-"
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
    plt.addDrawable(jLine);
    line = LineH(jLine,plt);
end

%function line = drawLine(varargin)
%    if mod(nargin,2) == 0
%        plt = cplt;
%    else
%        plt = varargin{1};
%        varargin = varargin(2:end);
%    end
%
%    defaultColor = [0 0 0];
%    defaultLabel = "";
%    defaultLabelAlpha = 1.0;
%    defaultVisible = true;
%    defaultLabelTextColor = [0,0,0];
%    defaultMarkerSize = 5.0;
%
%    p = inputParser;
%
%    addRequired(p,"X");
%    addRequired(p,"Y");
%    addParameter(p,"Color",defaultColor);
%    addParameter(p,"Label", defaultLabel);
%    addParameter(p,"LabelAlpha",defaultLabelAlpha);
%    addParameter(p,"Visible",defaultVisible);
%    addParameter(p,"LabelTextColor",defaultLabelTextColor);
%    addParameter(p,"LineWidth",defaultMarkerSize);
%    addParameter(p,"SizeOverride", -1);
%    addParameter(p,"LineStyle",'-')
%
%
%    parse(p,varargin{:});
%    
%    color = p.Results.Color;
%    if ~isnumeric(color)
%        switch color
%            case 'r'
%                color = [1 0 0];
%            case 'g'
%                color = [0 1 0];
%            case 'b'
%                color = [0 0 1];
%            case 'c'
%                color = [0 1 1];
%            case 'm'
%                color = [1 0 1];
%            case 'y'
%                color = [1 1 0];
%            case 'k'
%                color = [0 0 0];
%            case 'w'
%                color = [1 1 1];
%        end
%    end
%    
%    dashed = false;
%    if p.Results.LineStyle == "--"
%        dashed = true;
%    elseif p.Results.LineStyle ~= '-'
%        ME = MException("drawLine:invalidVariable only - or -- allowed");
%    throw(ME)
%    end
%
%    if p.Results.SizeOverride == -1
%        jLine = GeomatPlot.Draw.gLine(single(p.Results.X),single(p.Results.Y),color,p.Results.LineWidth,dashed);
%    else
%        jLine = GeomatPlot.Draw.gLine(single(zeros(1,p.Results.SizeOverride)),single(zeros(1,p.Results.SizeOverride)),color,p.Results.LineWidth,dashed);
%    end
%    plt.addDrawable(jLine);
%    line = LineH(jLine,plt);
%end

