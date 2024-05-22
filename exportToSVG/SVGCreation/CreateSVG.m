function CreateSVG(file, data, dashedEnabled, dottedEnabled, interactive, scale, shiftX, shiftY)

fprintf(file, '<svg id="canvas" xmlns="http://www.w3.org/2000/svg" onload="makeDraggable(evt)">\n');
if interactive
    fprintf(file, '<style>.draggable {cursor: move;}</style>');
end
fprintf(file, '<g id="viewport">');

for i=1:size(data,2)
        fprintf(file, "%s\n", ConvertType(data{i}, scale, shiftX, shiftY, dashedEnabled, dottedEnabled));
end

fprintf(file, '</g>');

if(interactive)
    ExportCallbacks(data, file);
end

fprintf(file, '</svg>');
    
end

