function elementDataStruct = DepDataCollector(FieldBuffer, FieldID)
    
    switch class(FieldBuffer)
        case "dpoint"       %mpoint will be a specific circle in svg so we collect data according
            
            elementDataStruct.type = "dpoint";
            elementDataStruct.title = FieldID;
            
            elementCoords = FieldBuffer.fig.Position;
            elementColor = FieldBuffer.fig.Color;
            elementCallback = func2str(FieldBuffer.callback);

            elementDataStruct.Position = elementCoords;
            elementDataStruct.Color = elementColor;
            elementDataStruct.callback = elementCallback;
            
        case "dcircle"

            elementDataStruct.type = "dcircle";
            elementDataStruct.title = FieldID;
            
            elementCenter = FieldBuffer.center.fig.Position;
            elementRadius = FieldBuffer.radius.val;
            elementColor = FieldBuffer.fig.Color;

            elementDataStruct.center = elementCenter;
            elementDataStruct.radius = elementRadius;
            elementDataStruct.Color = elementColor;

        case "dlines"

            elementDataStruct.type = "dlines";
            elementDataStruct.title = FieldID;

            % For now it will just take the first and last of the
            %   X and Y data, so instead of drawing the line with parts
            %   of lines it will just draw one long one, that most
            %   likely will be off, this will be tested and fixed if
            %   needed later
            
            elementXData = FieldBuffer.fig.XData;
            elementYData = FieldBuffer.fig.YData;
            elementColor = FieldBuffer.fig.Color;

            elementDataStruct.XData = elementXData;
            elementDataStruct.YData = elementYData;
            elementDataStruct.Color = elementColor;

        case "dvector"

            elementDataStruct.type = "dvector";
            elementDataStruct.title = FieldID;

            if class(FieldBuffer.fig) == "matlab.graphics.chart.primitive.Quiver"
                
                %export as an arrow later, now this will be handled as
                % a simple line

                elementXData = FieldBuffer.fig.XData(1);
                elementYData = FieldBuffer.fig.YData(1);
                elementDirection = FieldBuffer.val;
                elementColor = FieldBuffer.fig.Color;

                elementDataStruct.hidden = 0;
                elementDataStruct.XData = elementXData;
                elementDataStruct.YData = elementYData;
                elementDataStruct.val = elementDirection;
                elementDataStruct.Color = elementColor;

            else

                elementDirection = FieldBuffer.val;

                elementDataStruct.hidden = 0;
                elementDataStruct.val = elementDirection;

            end
            
            %elementCoords = FieldBuffer.fig.Position;
            %elementColor = FieldBuffer.fig.Color;

            %elementDataStruct.Position = elementCoords;
            %elementDataStruct.Color = elementColor;

        case "dpointseq"

            elementDataStruct.type = "dpointseq";
            elementDataStruct.title = FieldID;
            
            %elementCoords = FieldBuffer.fig.Position;
            %elementColor = FieldBuffer.fig.Color;

            %elementDataStruct.Position = elementCoords;
            %elementDataStruct.Color = elementColor;

        case "dpolygon"

            elementDataStruct.type = "dpolygon";
            elementDataStruct.title = FieldID;
            
            %elementCoords = FieldBuffer.fig.Position;
            %elementColor = FieldBuffer.fig.Color;

            %elementDataStruct.Position = elementCoords;
            %elementDataStruct.Color = elementColor;

        otherwise
            %error("Invalid movable type, or not yet documented movable type");
            elementDataStruct.type = "none";
    end
end

