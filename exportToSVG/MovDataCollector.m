function elementDataStruct = MovDataCollector(FieldBuffer, FieldID)
    
    switch class(FieldBuffer)
        case "mpoint"       %mpoint will be a specific circle in svg so we collect data according
            
            elementDataStruct.type = "mpoint";
            elementDataStruct.title = FieldID;
            
            elementCoords = FieldBuffer.fig.Position;
            elementColor = FieldBuffer.fig.Color;

            elementDataStruct.Position = elementCoords;
            elementDataStruct.Color = elementColor;
            
        case "mpolygon"

            elementDataStruct.type = "mpolygon";
            elementDataStruct.title = FieldID;
            
            elementCoords = FieldBuffer.fig.Position;
            elementColor = FieldBuffer.fig.Color;

            elementDataStruct.Position = elementCoords;
            elementDataStruct.Color = elementColor;

        otherwise
            error("Invalid movable type, or not yet documented movable type");
    end
    
end

