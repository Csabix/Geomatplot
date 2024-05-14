function ExportCallbacks(userData, outFile)
fprintf(outFile, '<script type="text/javascript" href="https://cdnjs.cloudflare.com/ajax/libs/mathjs/12.4.1/math.min.js"></script>\n');
fprintf(outFile, '<script type="text/javascript"><![CDATA[\n');

fprintf(outFile, GetDefinedCallback('makeDraggable', []));
fprintf(outFile, GetDefinedCallback('dragScreen', []));
fprintf(outFile, 'const config = { attributes: true, childList: false, subtree: true };');
fprintf(outFile, 'let temp;');
dependents = userData.deps;
dependentFields = fieldnames(dependents);

for i=1:numel(dependentFields)    %Iterating through dependent fields

FieldBuffer = dependents.(dependentFields{i});  %actual field of the dependents that we are currently working with


% Temporarily I will start coding the callback export here.
%   Should move it into separate function later on.

    if isequal(functions(FieldBuffer.callback).type, 'anonymous')
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
                fprintf(outFile, GetDefinedCallback("dcircleDefaultCallback", FieldBuffer.inputs, FieldBuffer.label));
            end % if
        otherwise
            % do something with abstract function

        end % inside switch
    end % if anonymous
    
    fprintf(outFile, GetDefinedCallback(func2str(FieldBuffer.callback), FieldBuffer.inputs, FieldBuffer.label));

end % for loop

% mpolygon callback can only be done this way sadly
moveables = userData.movs;
moveableFields = fieldnames(moveables);

for i=1:numel(moveableFields)

    FieldBuffer = moveables.(moveableFields{i});
    if isequal(class(FieldBuffer), 'mpolygon')
        fprintf(outFile, GetDefinedCallback("mpolygon", {}, FieldBuffer.label));
    end % if
end % moveable

fprintf(outFile, ']]></script>\n');
end

