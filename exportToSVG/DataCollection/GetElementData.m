function elementDataStruct = GetElementData(FieldBuffer, FieldID)
    
    % isa(userData.movs.A, 'dependent') should check this
    % should group up the points under point_base class

    switch class(FieldBuffer)
        case "mpoint"       %mpoint will be a specific circle in svg so we collect data according
            
            elementDataStruct.type = "mpoint";
            elementDataStruct.label = FieldID;
            
            elementCoords = FieldBuffer.fig.Position;
            elementColor = FieldBuffer.fig.Color;

            elementDataStruct.Position = elementCoords;
            elementDataStruct.Color = elementColor;
            
        case "mpolygon"

            elementDataStruct.type = "mpolygon";
            elementDataStruct.label = FieldID;
            
            elementDataStruct.Position = FieldBuffer.fig.Position;

            elementDataStruct.Color = FieldBuffer.fig.Color;
            elementDataStruct.LineWidth = FieldBuffer.fig.LineWidth;

        case "dpoint"
            
            elementDataStruct.type = "dpoint";
            elementDataStruct.label = FieldID;

            elementDataStruct.Position = FieldBuffer.fig.Position;
            elementDataStruct.Color = FieldBuffer.fig.Color;

            elementDataStruct.callback = FieldBuffer.callback;
            elementDataStruct.inputs = FieldBuffer.inputs;
            
        case "dcircle"

            elementDataStruct.type = "dcircle";
            elementDataStruct.label = FieldID;

            elementDataStruct.center = FieldBuffer.center.fig.Position;
            elementDataStruct.radius = FieldBuffer.radius.val;
            elementDataStruct.Color = FieldBuffer.fig.Color;

            elementDataStruct.callback = FieldBuffer.callback;
            elementDataStruct.inputs = FieldBuffer.inputs;

        case "dlines"

            elementDataStruct.type = "dlines";
            elementDataStruct.label = FieldID;

            elementDataStruct.XData = FieldBuffer.fig.XData;
            elementDataStruct.YData = FieldBuffer.fig.YData;

            elementDataStruct.Color = FieldBuffer.fig.Color;
            elementDataStruct.LineStyle = FieldBuffer.fig.LineStyle;
            elementDataStruct.LineWidth = FieldBuffer.fig.LineWidth;

            elementDataStruct.callback = FieldBuffer.callback;
            elementDataStruct.inputs = FieldBuffer.inputs;

        case "dvector"

            elementDataStruct.type = "dvector";
            elementDataStruct.label = FieldID;

            if class(FieldBuffer.fig) == "matlab.graphics.chart.primitive.Quiver"
                
                %export as an arrow later, now this will be handled as
                % a simple line

                elementDataStruct.hidden = 0;
                elementDataStruct.XData = FieldBuffer.fig.XData(1);
                elementDataStruct.YData = FieldBuffer.fig.YData(1);
                elementDataStruct.val = FieldBuffer.val;
                elementDataStruct.Color = FieldBuffer.fig.Color;

            else

                elementDirection = FieldBuffer.val;

                elementDataStruct.hidden = 0;
                elementDataStruct.val = elementDirection;

            end

            elementDataStruct.callback = FieldBuffer.callback;
            elementDataStruct.inputs = FieldBuffer.inputs;

        case "dpolygon"

            elementDataStruct.type = "dpolygon";
            elementDataStruct.label = FieldID;
            
            elementDataStruct.XData = FieldBuffer.fig.XData;
            elementDataStruct.YData = FieldBuffer.fig.YData;

            elementDataStruct.FaceColor = FieldBuffer.fig.FaceColor;
            elementDataStruct.FaceAlpha = FieldBuffer.fig.FaceAlpha;

            elementDataStruct.EdgeColor = FieldBuffer.fig.EdgeColor;
            elementDataStruct.LineStyle = FieldBuffer.fig.LineStyle;
            elementDataStruct.LineWidth = FieldBuffer.fig.LineWidth;

            elementDataStruct.callback = FieldBuffer.callback;
            elementDataStruct.inputs = FieldBuffer.inputs;

        case "dscalar"
            elementDataStruct.type = "dscalar";
            elementDataStruct.label = FieldID;

            elementDataStruct.val = FieldBuffer.val;

            elementDataStruct.callback = FieldBuffer.callback;
            elementDataStruct.inputs = FieldBuffer.inputs;

        otherwise
            %error("Invalid movable type, or not yet documented movable type");
            elementDataStruct.type = "none";
    end
end

