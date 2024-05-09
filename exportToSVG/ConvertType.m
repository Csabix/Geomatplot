function svgLine = ConvertType(plotData, scale, shiftX, shiftY, dashedEnabled, dottedEnabled)

    switch plotData.type
        case 'mpoint'
            
            cx = TransformCoordinate(plotData.Position(1), false, scale, shiftX);
            cy = TransformCoordinate(plotData.Position(2), true, scale, shiftY);
            
            [r,g,b] = GetRGBFromFigColor(plotData.Color);
            
            svgLine = strcat('<circle id="', plotData.title,'" class="draggable" r="5" cx="', string(cx), '" cy="', string(cy));
            svgLine = strcat(svgLine, '" fill="rgb(', string(r), ', ', string(g), ', ', string(b), ')" />');
        
        case 'mpolygon'

            % Need to make a group here that groups the polygon and it's
            % points, and make the polygon repsonsive to the points
            
            xData = TransformCoordinateDataFromFig(plotData.Position(:,1), false, scale, shiftX);
            yData = TransformCoordinateDataFromFig(plotData.Position(:,2), true, scale, shiftY);

            [r,g,b] = GetRGBFromFigColor(plotData.Color);

            
            svgLine = strcat('<g id="',plotData.title,'">');
            svgLine = strcat(svgLine, '<polygon points="');
            for k=1:numel(xData)
                svgLine = strcat(svgLine, string(xData(k)), ',', string(yData(k)),{' '});
                %if isequal(k, numel(xData)) == false
                %    svgLine = strcat(svgLine);
                %end
            end
            svgLine = strcat(svgLine, '" style="fill:rgba(', string(r), ', ', string(g), ', ', string(b), ', ', string(0.1));
            svgLine = strcat(svgLine,');stroke:rgb(', string(r), ', ', string(g), ', ', string(b), ');stroke-width:',string(plotData.LineWidth),'"/>');
            for k=1:numel(xData)
                svgLine = strcat(svgLine, '<circle id="', string(k),'" class="draggable" r="5" cx="', string(xData(k)), '" cy="', string(yData(k)));
                svgLine = strcat(svgLine, '" fill="rgb(', string(r), ', ', string(g), ', ', string(b), ')" />');
            end
            svgLine = strcat(svgLine,'</g>');
        
        case 'dpoint'
            
            cx = TransformCoordinate(plotData.Position(1), false, scale, shiftX);
            cy = TransformCoordinate(plotData.Position(2), true, scale, shiftY);
            
            [r,g,b] = GetRGBFromFigColor(plotData.Color);
            
            svgLine = strcat('<circle id="', plotData.title,'" r="5" cx="', string(cx), '" cy="', string(cy));
            svgLine = strcat(svgLine, '" fill="rgb(', string(r), ', ', string(g), ', ', string(b), ')" />');
        
        case 'dlines'

            width = plotData.LineWidth;
            style = LineStyleMatcher(plotData.LineStyle, dashedEnabled, dottedEnabled);

            if isequal(size(plotData.XData, 2), 2) & isequal(size(plotData.XData), size(plotData.YData))
    
                xData = TransformCoordinateDataFromFig(plotData.XData, false, scale, shiftX);
                yData = TransformCoordinateDataFromFig(plotData.YData, true, scale, shiftY);

                [r,g,b] = GetRGBFromFigColor(plotData.Color);
                
                svgLine = strcat('<line id="', plotData.title,'" x1="', string(xData(1)), '" y1="', string(yData(1)), '" x2="', string(xData(2)), '" y2="', string(yData(2)), '"');
                svgLine = strcat(svgLine, ' stroke="rgb(', string(r), ', ', string(g), ', ', string(b), ')" stroke-width="', string(width),'" ',style,' />');

            else
                xData = TransformCoordinateDataFromFig(plotData.XData, false, scale, shiftX);
                yData = TransformCoordinateDataFromFig(plotData.YData, true, scale, shiftY);

                [r,g,b] = GetRGBFromFigColor(plotData.Color);
                svgLine = strcat('<g id="',plotData.title,'">');
                j=1;
                for i=1:(size(xData, 2) - 1)
                    
                    if ~isnan(xData(i)) && ~isnan(xData(i+1))
                        svgLine = strcat(svgLine, '<line id="',string(j),'" x1="', string(xData(i)), '" y1="', string(yData(i)), '" x2="', string(xData(i+1)), '" y2="', string(yData(i+1)), '"');
                        svgLine = strcat(svgLine, ' stroke="rgb(', string(r), ', ', string(g), ', ', string(b), ')" stroke-width="', string(width),'" ',style,' />');
                        j = j + 1;
                    end
                    
                end
                svgLine = strcat(svgLine,'</g>');
           end

        case 'dcircle'

            cx = TransformCoordinate(plotData.center(1), false, scale, shiftX);
            cy = TransformCoordinate(plotData.center(2), true, scale, shiftY);
    
            radius = plotData.radius * scale;
    
            [r,g,b] = GetRGBFromFigColor(plotData.Color);

            svgLine = strcat('<circle id="', plotData.title,'" r="', string(radius),'" cx="', string(cx), '" cy="', string(cy));
            svgLine = strcat(svgLine, '" fill="none" stroke-width="2" stroke="rgb(', string(r), ', ', string(g), ', ', string(b), ')" />');
       
        case 'dscalar'

            % Should look for a better element that doesn't need to be
            % drawn

            value = plotData.val * scale;

            svgLine = strcat('<circle id="', plotData.title,'" r="0" cx="0" cy="0"');
            svgLine = strcat(svgLine, ' value="', string(value),'" visibility="hidden" />');

        case 'dpolygon'

            xData = TransformCoordinateDataFromFig(plotData.XData, false, scale, shiftX);
            yData = TransformCoordinateDataFromFig(plotData.YData, true, scale, shiftY);

            [faceR,faceG,faceB] = GetRGBFromFigColor(plotData.FaceColor);
            [edgeR,edgeG,edgeB] = GetRGBFromFigColor(plotData.EdgeColor);

            style = LineStyleMatcher(plotData.LineStyle, dashedEnabled, dottedEnabled);

            svgLine = strcat('<polygon id="', plotData.title,'" points="');
            for k=1:numel(xData)
                svgLine = strcat(svgLine, string(xData(k)), ',', string(yData(k)),{' '});
                %if isequal(k, numel(xData)) == false
                %    svgLine = strcat(svgLine);
                %end
            end
            svgLine = strcat(svgLine, '" style="fill:rgba(', string(faceR), ', ', string(faceG), ', ', string(faceB),', ', string(plotData.FaceAlpha));
            svgLine = strcat(svgLine,');stroke:rgb(', string(edgeR), ', ', string(edgeG), ', ', string(edgeB), ');stroke-width:',string(plotData.LineWidth),'"', style,'/>');
        

        otherwise
            svgLine = "";
    end
end

function returnCoordData = TransformCoordinateDataFromFig(coordData, flip, scale, shift)
    returnCoordData = zeros(size(coordData));
    for i=1:numel(coordData)
        returnCoordData(i) = TransformCoordinate(coordData(i), flip, scale, shift);
    end
end

function returnCoord = TransformCoordinate(coordinate, flip, scale, shift)

    returnCoord = coordinate;
    
    if flip
        returnCoord = -returnCoord;
    end
    
    returnCoord = returnCoord * scale;
    returnCoord = returnCoord + shift;

end

function [r,g,b] = GetRGBFromFigColor(color)
    defaultColor = {250,250,250};
    if isequal(numel(color), 3)
        r = ConvertUnitIntervalToRGB(color(1));
        g = ConvertUnitIntervalToRGB(color(2));
        b = ConvertUnitIntervalToRGB(color(3));
    else
        [r,g,b] = defaultColor{:};
    end
end

function returnRGB = ConvertUnitIntervalToRGB(num)
    returnRGB = fix(num * 256);
end
