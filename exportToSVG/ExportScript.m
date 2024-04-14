function ExportScript(userData, outFile)
    fprintf(outFile, '<script type="text/javascript" href="https://cdnjs.cloudflare.com/ajax/libs/mathjs/12.4.1/math.min.js"/>\n');
    fprintf(outFile, '<script type="text/javascript"><![CDATA[\n');

    fprintf(outFile, GetDraggableFunction());
    fprintf(outFile, 'const config = { attributes: true, childList: false, subtree: false };');
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
                        
                        if isequal(size(FieldBuffer.inputs, 2),2) && isequal(class(FieldBuffer.inputs{1}),'mpoint') && isequal(class(FieldBuffer.inputs{2}),'mpoint')
                            disp(FieldBuffer.inputs{1});
                            disp(FieldBuffer.inputs{2});
                        end

                end


            otherwise
        end


    end

    fprintf(outFile, ']]></script>\n');
end

