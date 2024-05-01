function exportToSvg(g, location, dashedEnabled, dottedEnabled, interactive)
    
    if(~isequal(class(findobj), 'matlab.graphics.Graphics'))
        throw(MException('MATLAB:notEnoughInputs','Error! There are no plots to export!\nHiba! Nincs exportálható adat'));
    end
    
    userData = get(g, 'UserData');
    
    if(~isequal(class(userData), 'Geomatplot'))
        fig = get(g,'parent');
        close(fig);
        error('Error! This plot cannot be exported (not made with Geomatplot)\nHiba! Ez a koordinátarendszer nem Geomatplottal lett létrehozva');
    end

    rawData = DataSweeper(userData);
    rawDataSize = size(rawData);
    
    outFile = fopen(strcat(location,'/export.svg'),'w');
    
    fprintf(outFile, '<svg xmlns="http://www.w3.org/2000/svg" onload="makeDraggable(evt)">\n');

    xWidth = g.XLim(2) - g.XLim(1);
    yWidth = g.YLim(2) - g.YLim(1);

    minWidth = min([xWidth, yWidth]);
    
    for i=1:rawDataSize(2)

        fprintf(outFile, "%s\n", TypeMatcher(rawData{i}, 500 / minWidth, dashedEnabled, dottedEnabled));
        
    end

    if(interactive)
        ExportScript(userData, outFile);
    end
    fprintf(outFile, '</svg>');
    fclose(outFile);
    
end