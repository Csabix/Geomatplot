function exportsvg(g, location, dashedEnabled, dottedEnabled, interactive, scale, shiftX, shiftY)

    userData = get(g, 'UserData');
    
    if isempty(get(g, 'UserData'))
        fig = get(g,'parent');
        close(fig);
        error("Error! There are no plots to export!\nHiba! Nincs exportálható adat");
    end
    
    if ~isequal(class(userData), 'Geomatplot')
        fig = get(g,'parent');
        close(fig);
        error("Error! This plot cannot be exported (not made with Geomatplot)\nHiba! Ez a koordinátarendszer nem Geomatplottal lett létrehozva");
    end

    locationDefault = './export.svg';
    dashedEnabledDefault = true;
    dottedEnabledDefault = true;
    interactiveDefault = true;
    scaleDefault = 500;
    shiftXDefault = 250;
    shiftYDefault = 500;

    if ~exist('location','var') || isempty(location)
        location=locationDefault;
    end

    if ~exist('dashedEnabled','var') || isempty(dashedEnabled)
        dashedEnabled=dashedEnabledDefault;
    end

    if ~exist('dottedEnabled','var') || isempty(dottedEnabled)
        dottedEnabled=dottedEnabledDefault;
    end

    if ~exist('interactive','var') || isempty(interactive)
        interactive=interactiveDefault;
    end

    if ~exist('scale','var') || isempty(scale)
        scale=scaleDefault;
    end

    if ~exist('shiftX','var') || isempty(shiftX)
        shiftX=shiftXDefault;
    end

    if ~exist('shiftY','var') || isempty(shiftY)
        shiftY=shiftYDefault;
    end

    rawData = ExtractUserData(userData);
    
    CorrectLocationName(location);
    outFile = fopen(location,'w');

    xWidth = g.XLim(2) - g.XLim(1);
    yWidth = g.YLim(2) - g.YLim(1);

    minWidth = min([xWidth, yWidth]);

    CreateSVG(outFile, rawData, dashedEnabled, dottedEnabled, interactive,  (scale / minWidth), shiftX, shiftY);
    
    fclose(outFile);
    
end

function CorrectLocationName(location)
    if numel(location) <= 3
        strcat(location, '.svg');
    elseif ~isequal(location(numel(location)-3:numel(location)), '.svg')
        strcat(location, '.svg');
    end
end