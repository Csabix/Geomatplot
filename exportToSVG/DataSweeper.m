function outList = DataSweeper(userData)
    
    % this function is only for collecting the data raw, and then returning
    %   a list of the corrected, data. This function should never meddle
    %   with the data, or modify it in any way. Only get the raw data in an
    %   structured array.
    
    outList = {};

    movables = userData.movs;
    movableFields = fieldnames(movables);

    dependents = userData.deps;
    dependentFields = fieldnames(dependents);
    
    for i=1:numel(movableFields)    %Iterating through movable fields
        
        FieldBuffer = movables.(movableFields{i});   %actual field of the movables that we are currently working with
        elementDataStruct = struct();           %empty struct for collected data, assigned based on class

        switch class(FieldBuffer)
            case "mpoint"       %mpoint will be a specific circle in svg so we collect data according
                
                elementDataStruct.type = "mpoint";
                elementDataStruct.title = movableFields{i};
                
                elementCoords = FieldBuffer.fig.Position;
                elementColor = FieldBuffer.fig.Color;

                elementDataStruct.Position = elementCoords;
                elementDataStruct.Color = elementColor;
                
            case "mpolygon"

                elementDataStruct.type = "mpolygon";
                elementDataStruct.title = movableFields{i};
                
                elementCoords = FieldBuffer.fig.Position;
                elementColor = FieldBuffer.fig.Color;

                elementDataStruct.Position = elementCoords;
                elementDataStruct.Color = elementColor;

            otherwise
                error("Invalid movable type, or not yet documented movable type");
        end

        outList{i} = elementDataStruct;
        
    end

    
    
    for i=1:numel(dependentFields)    %Iterating through dependent fields

        FieldBuffer = dependents.(dependentFields{i});   %actual field of the movables that we are currently working with
        elementDataStruct = struct();           %empty struct for collected data, assigned based on class

        switch class(FieldBuffer)
            case "dpoint"       %mpoint will be a specific circle in svg so we collect data according
                
                elementDataStruct.type = "dpoint";
                elementDataStruct.title = dependentFields{i};
                
                elementCoords = FieldBuffer.fig.Position;
                elementColor = FieldBuffer.fig.Color;
                elementCallback = func2str(FieldBuffer.callback);

                elementDataStruct.Position = elementCoords;
                elementDataStruct.Color = elementColor;
                elementDataStruct.callback = elementCallback;
                
            case "dcircle"

                elementDataStruct.type = "dcircle";
                
                %elementCoords = FieldBuffer.fig.Position;
                elementColor = FieldBuffer.fig.Color;

                %elementDataStruct.Position = elementCoords;
                elementDataStruct.Color = elementColor;

            case "dlines"

                elementDataStruct.type = "dlines";
                
                %elementCoords = FieldBuffer.fig.Position;
                %elementColor = FieldBuffer.fig.Color;

                %elementDataStruct.Position = elementCoords;
                %elementDataStruct.Color = elementColor;

            case "dvector"

                elementDataStruct.type = "dvector";
                
                %elementCoords = FieldBuffer.fig.Position;
                %elementColor = FieldBuffer.fig.Color;

                %elementDataStruct.Position = elementCoords;
                %elementDataStruct.Color = elementColor;

            otherwise
                %error("Invalid movable type, or not yet documented movable type");
        end

        outList{(numel(movableFields) + 1)} = elementDataStruct;
        

    end
end

