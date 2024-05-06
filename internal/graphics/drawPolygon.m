function polygon = drawPolygon(varargin)
    if mod(nargin,2) == 0
        plt = cplt;
    else
        plt = varargin{1};
        varargin = varargin(2:end);
    end

    defaultPostion = [];
    defaultPrimaryColor = [0 0.4470 0.7410];
    defaultBorderColor = [0 0 0];
    dafaultFaceAlpha = 0.2;
    defaultMovable = true;
    defaultReshapable = true;

    p = inputParser;
    p.KeepUnmatched = true;

    addParameter(p,"Position", defaultPostion);
    addParameter(p,"Color",defaultPrimaryColor);
    addParameter(p,"ColorBorder",defaultBorderColor);
    addParameter(p,"FaceAlpha",dafaultFaceAlpha)
    addParameter(p,"Movable",defaultMovable);
    addParameter(p,"Reshapable", defaultReshapable)

    parse(p,varargin{:});

    colorPrimary = p.Results.Color;
    if ~isnumeric(colorPrimary)
        colorPrimary = parseColor(colorPrimary);
    end

    colorBorder = p.Results.ColorBorder;
    if ~isnumeric(colorBorder)
        colorBorder = parseColor(colorBorder);
    end

    P = p.Results.Position;
    x = [];
    y = [];
    if isempty(P)
        points = [];

        clickInput = plt.JClickInput;
        clickInput.getInput;
        while(~clickInput.isButton(3))
            x = clickInput.xy(1);
            y = clickInput.xy(2);
            point = GeomatPlot.Draw.gPoint(x,y,false);
            plt.addDrawable(point);
            points = [points, point];
            clickInput.getInput;
        end
    
        count = numel(points);
        x = zeros(1, count);
        y = zeros(1, count);
    
        for i = 1:count
            x(i) = points(i).x;
            y(i) = points(i).y;
        end

        plt.removeDrawable(points);
    else
        x = P(:,1);
        y = P(:,2);
    end
    
    [x,y,indices] = PolygonH.calcDeluany(x,y);

    jPolygon = [];
    if(p.Results.Reshapable)
        jPolygon = GeomatPlot.Draw.gPolygon(x,y, indices-1, colorPrimary,colorBorder,p.Results.FaceAlpha,p.Results.Movable);
    else
        jPolygon = GeomatPlot.Draw.gPatch(x,y, indices-1, colorPrimary,colorBorder,p.Results.FaceAlpha,p.Results.Movable);
    end
    plt.addDrawable(jPolygon);
    polygon = PolygonH(jPolygon,plt);
end

%function [polygon, indices] = drawPolygon(varargin)
%    plt = cplt;
%
%    points = [];
%
%    clickInput = plt.JClickInput;
%    clickInput.getInput;
%    while(~clickInput.isButton(3))
%        x = clickInput.xy(1);
%        y = clickInput.xy(2);
%        point = GeomatPlot.Draw.gPoint(x,y,false);
%        plt.addDrawable(point);
%        points = [points, point];
%        clickInput.getInput;
%    end
%    
%    count = numel(points);
%    x = zeros(1, count);
%    y = zeros(1, count);
%
%    for i = 1:count
%        x(i) = points(i).x;
%        y(i) = points(i).y;
%    end
%    
%    [x,y,indices] = PolygonH.calcDeluany(x,y);
%    plt.removeDrawable(points);
%
%    jPolygon = GeomatPlot.Draw.gPolygon(x,y, indices-1, [0,1,0],[0,0,0],1,true);
%    plt.addDrawable(jPolygon);
%    polygon = PointH(jPolygon,plt);
%end