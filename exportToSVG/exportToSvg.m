function exp = exportToSvg(g)
    
    userData = get(g, 'UserData');
    
    rawData = DataSweeper(userData);
    rawDataSize = size(rawData);
    
    outFile = fopen('export.svg','w');
    
    fprintf(outFile, '<svg xmlns="http://www.w3.org/2000/svg" onload="makeDraggable(evt)">\n');

    xWidth = g.XLim(2) - g.XLim(1);
    yWidth = g.YLim(2) - g.YLim(1);

    minWidth = min([xWidth, yWidth]);
    
    for i=1:rawDataSize(2)

        fprintf(outFile, "%s\n", TypeMatcher(rawData{i}, 500 / minWidth));
        
    end

    ExportScript(userData, outFile);

    fprintf(outFile, '</svg>');
    fclose(outFile);
    
end