function ExportScript(userData, outFile)
    fprintf(outFile, '<script type="text/javascript" href="https://cdnjs.cloudflare.com/ajax/libs/mathjs/12.4.1/math.min.js"/>\n');
    fprintf(outFile, '<script type="text/javascript"><![CDATA[\n');

    fprintf(outFile, GetDraggableFunction());

    fprintf(outFile, ']]></script>\n');
end

