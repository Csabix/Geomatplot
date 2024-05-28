function exportsvg(g, location, dashedEnabled, dottedEnabled, interactive, scale, shiftX, shiftY)
    
    userData = get(g, 'UserData');

    if isempty(userData)
        error("There are no plots to export! | Nincs exportálható adat");
    elseif ~isequal(class(userData), 'Geomatplot')
        error("Data is not type of Geomatplot! | Az adatok nem Geomatplot típusúak");
    end

    locationDefault = './export.svg';
    dashedEnabledDefault = true;
    dottedEnabledDefault = true;
    interactiveDefault = true;
    scaleDefault = 500;
    shiftXDefault = 250;
    shiftYDefault = 500;

    if ~exist('location','var') || isempty(location) || isequal(location, '')
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
    %disp(location);
    
    try
        location = CorrectLocationName(location);
        outFile = fopen(location,'w');
    catch e
        error("Error! Invalid file name\nHiba! Rossz fájl név");
    end

    xWidth = g.XLim(2) - g.XLim(1);
    yWidth = g.YLim(2) - g.YLim(1);

    maxWidth = max([xWidth, yWidth]);
    CreateSVG(outFile, rawData, dashedEnabled, dottedEnabled, interactive,  (scale / maxWidth), shiftX, shiftY);
    
    fclose(outFile);
    
end

function loc = CorrectLocationName(location)
    loc = location;
    if isfolder(location)
        loc = strcat(location, 'export.svg');
    elseif numel(location) > 0 && numel(location) <= 3
        loc = strcat(location, '.svg');
    elseif ~isequal(location(numel(location)-3:numel(location)), '.svg')
        loc = strcat(location, '.svg');
    end
end