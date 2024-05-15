function ExportCallbacks(data, file)
fprintf(file, '<script type="text/javascript" href="https://cdnjs.cloudflare.com/ajax/libs/mathjs/12.4.1/math.min.js"></script>\n');
fprintf(file, '<script type="text/javascript"><![CDATA[\n');

fprintf(file, GetDefinedCallback('makeDraggable', []));
fprintf(file, GetDefinedCallback('dragScreen', []));
fprintf(file, 'const config = { attributes: true, childList: false, subtree: true };');
fprintf(file, 'let temp;');

for i=1:size(data, 2)

    fieldBuffer = data{i};

    if isequal(fieldBuffer.type, 'mpoint')
        continue;
    end

    if isequal(fieldBuffer.type, 'dlines') && ...
            drawing.isInputPatternMatching(fieldBuffer.inputs,{'point_base','point_base'}) && ...
            isequal(func2str(fieldBuffer.callback), '@(a,b)a.value+(b.value-a.value).*[0;1]')
        temp = "temp = new MutationObserver((mutationList, observer) => {for (const mutation of mutationList) {if (mutation.type === 'attributes') {if(mutation.attributeName === 'cx'){\n";
        temp = temp + "document.getElementById('"+string(fieldBuffer.label)+"').setAttributeNS(null, 'x1', document.getElementById('"+string(fieldBuffer.inputs{1}.label)+"').getAttributeNS(null, mutation.attributeName));\n";
        temp = temp + "document.getElementById('"+string(fieldBuffer.label)+"').setAttributeNS(null, 'x2', document.getElementById('"+string(fieldBuffer.inputs{2}.label)+"').getAttributeNS(null, mutation.attributeName));\n}";
        temp = temp + "if(mutation.attributeName === 'cy'){\n";
        temp = temp + "document.getElementById('"+string(fieldBuffer.label)+"').setAttributeNS(null, 'y1', document.getElementById('"+string(fieldBuffer.inputs{1}.label)+"').getAttributeNS(null, mutation.attributeName));";
        temp = temp + "document.getElementById('"+string(fieldBuffer.label)+"').setAttributeNS(null, 'y2', document.getElementById('"+string(fieldBuffer.inputs{2}.label)+"').getAttributeNS(null, mutation.attributeName));}}}});\n";
        temp = temp + "temp.observe(document.getElementById('"+string(fieldBuffer.inputs{1}.label)+"'), config);temp.observe(document.getElementById('"+string(fieldBuffer.inputs{2}.label)+"'), config);\n";
        fprintf(file, temp);
    elseif isequal(fieldBuffer.type, 'dcircle') && isequal(class(fieldBuffer.inputs{2}),'dscalar')
        fprintf(file, GetDefinedCallback("dcircleDefaultCallback", fieldBuffer.inputs, fieldBuffer.label));
    elseif isequal(class(fieldBuffer), 'mpolygon')
        fprintf(file, GetDefinedCallback("mpolygon", {}, fieldBuffer.label));
    else
        fprintf(file, GetDefinedCallback(func2str(fieldBuffer.callback), fieldBuffer.inputs, fieldBuffer.label));
    end

end

fprintf(file, ']]></script>\n');
end
