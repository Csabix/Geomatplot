function ExportScript(userData, outFile)
fprintf(outFile, '<script type="text/javascript" href="https://cdnjs.cloudflare.com/ajax/libs/mathjs/12.4.1/math.min.js"/>\n');
fprintf(outFile, '<script type="text/javascript"><![CDATA[\n');

fprintf(outFile, GetBasicFunction('makeDraggable', []));
fprintf(outFile, 'const config = { attributes: true, childList: false, subtree: false };');
fprintf(outFile, 'let temp;');
dependents = userData.deps;
dependentFields = fieldnames(dependents);

for i=1:numel(dependentFields)    %Iterating through dependent fields

FieldBuffer = dependents.(dependentFields{i});  %actual field of the movables that we are currently working with
disp(FieldBuffer.callback);

% Temporarily I will start coding the callback export here.
%   Should move it into separate function later on.

    switch functions(FieldBuffer.callback).type
    case "anonymous"
        switch class(FieldBuffer)
        case "dlines"
            if isequal(size(FieldBuffer.inputs, 2),2) && ...
            isequal(class(FieldBuffer.inputs{1}),'mpoint') || isequal(class(FieldBuffer.inputs{1}),'dpoint') && ...
            isequal(class(FieldBuffer.inputs{2}),'mpoint') || isequal(class(FieldBuffer.inputs{2}),'dpoint') && ...
            isequal(func2str(FieldBuffer.callback), '@(a,b)a.value+(b.value-a.value).*[0;1]')
                temp = "temp = new MutationObserver((mutationList, observer) => {for (const mutation of mutationList) {if (mutation.type === 'attributes') {if(mutation.attributeName === 'cx'){\n";
                temp = temp + "document.getElementById('"+string(FieldBuffer.label)+"').setAttributeNS(null, 'x1', document.getElementById('"+string(FieldBuffer.inputs{1}.label)+"').getAttributeNS(null, mutation.attributeName));\n";
                temp = temp + "document.getElementById('"+string(FieldBuffer.label)+"').setAttributeNS(null, 'x2', document.getElementById('"+string(FieldBuffer.inputs{2}.label)+"').getAttributeNS(null, mutation.attributeName));\n}";
                temp = temp + "if(mutation.attributeName === 'cy'){\n";
                temp = temp + "document.getElementById('"+string(FieldBuffer.label)+"').setAttributeNS(null, 'y1', document.getElementById('"+string(FieldBuffer.inputs{1}.label)+"').getAttributeNS(null, mutation.attributeName));";
                temp = temp + "document.getElementById('"+string(FieldBuffer.label)+"').setAttributeNS(null, 'y2', document.getElementById('"+string(FieldBuffer.inputs{2}.label)+"').getAttributeNS(null, mutation.attributeName));}}}});\n";
                temp = temp + "temp.observe(document.getElementById('"+string(FieldBuffer.inputs{1}.label)+"'), config);temp.observe(document.getElementById('"+string(FieldBuffer.inputs{2}.label)+"'), config);\n";
                fprintf(outFile, temp);
            end % if
        case "dcircle"
            if isequal(class(FieldBuffer.inputs{2}),'dscalar')
                fprintf(outFile, GetBasicFunction("dcircleDefaultCallback", {FieldBuffer.inputs{1}, FieldBuffer.inputs{2}, FieldBuffer}));
            end % if
        end % inside switch
    otherwise
        if isequal(class(FieldBuffer), 'dscalar')
            fprintf(outFile, GetBasicFunction(func2str(FieldBuffer.callback), {FieldBuffer.inputs{1}, FieldBuffer.inputs{2}, FieldBuffer}));
        end % if
    end % outside switch
end % for loop
fprintf(outFile, ']]></script>\n');
end

