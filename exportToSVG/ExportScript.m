function ExportScript(userData, outFile)
    fprintf(outFile, '<script type="text/javascript" href="https://cdnjs.cloudflare.com/ajax/libs/mathjs/12.4.1/math.min.js"/>\n');
    fprintf(outFile, '<script type="text/javascript"><![CDATA[\n');

    fprintf(outFile, GetDraggableFunction());

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
                        
                        cbString = func2str(FieldBuffer.callback);

                        disp(regexp(cbString, '.+?)', 'match'));

                        % regexp(func2str(userData.deps.seg1.callback), '.+?(?=))', 'match')
                        % math.multiply(math.transpose([[1, 2]]), [[1, 2]])

                end


            otherwise
        end


    end

    fprintf(outFile, ']]></script>\n');
end

