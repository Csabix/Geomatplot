function svgLine = TypeMatcher(plotData, scale)
    
    disp(plotData.type);

    switch plotData.type
        case 'mpoint'
            
            cx = plotData.Position(1) * scale + 250;
            cy = 500 - (plotData.Position(2) * scale);
            
            r = fix(256 * plotData.Color(1));
            g = fix(256 * plotData.Color(2));
            b = fix(256 * plotData.Color(3));
            
            svgLine = strcat('<circle class="', plotData.title,'" r="5" cx="', string(cx), '" cy="', string(cy));
            svgLine = strcat(svgLine, '" fill="rgb(', string(r), ', ', string(g), ', ', string(b), ')" />');
        
        case 'dpoint'
            
            cx = plotData.Position(1) * scale + 250;
            cy = 500 - (plotData.Position(2) * scale);
            
            r = fix(256 * plotData.Color(1));
            g = fix(256 * plotData.Color(2));
            b = fix(256 * plotData.Color(3));
            
            svgLine = strcat('<circle class="', plotData.title,'" r="5" cx="', string(cx), '" cy="', string(cy));
            svgLine = strcat(svgLine, '" fill="rgb(', string(r), ', ', string(g), ', ', string(b), ')" />');
        
        case 'dlines'

            if isequal(size(plotData.XData, 2), 2) & isequal(size(plotData.XData), size(plotData.YData))
    
                x1 = plotData.XData(1) * scale + 250;
                y1 = 500 - (plotData.YData(1) * scale);
    
                x2 = plotData.XData(2) * scale + 250;
                y2 = 500 - (plotData.YData(2) * scale);
    
                r = fix(256 * plotData.Color(1));
                g = fix(256 * plotData.Color(2));
                b = fix(256 * plotData.Color(3));
                
                svgLine = strcat('<line class="', plotData.title,'" x1="', string(x1), '" y1="', string(y1), '" x2="', string(x2), '" y2="', string(y2), '"');
                svgLine = strcat(svgLine, ' style="stroke:rgb(', string(r), ', ', string(g), ', ', string(b), ');stroke-width:2" />');

            elseif isequal(mod(size(plotData.XData, 2), 2), 0) & isequal(size(plotData.XData), size(plotData.YData))

                svgLine = "";

                disp("Multiple lines here, Line:");

                for i=1:(size(plotData.XData, 2) - 1)
                    disp(i);
                    x1 = plotData.XData(i) * scale + 250;
                    y1 = 500 - (plotData.YData(i) * scale);
        
                    x2 = plotData.XData(i + 1) * scale + 250;
                    y2 = 500 - (plotData.YData(i + 1) * scale);
        
                    r = fix(256 * plotData.Color(1));
                    g = fix(256 * plotData.Color(2));
                    b = fix(256 * plotData.Color(3));
                    
                    svgLine = strcat(svgLine, '<line class="', plotData.title,'" x1="', string(x1), '" y1="', string(y1), '" x2="', string(x2), '" y2="', string(y2), '"');
                    svgLine = strcat(svgLine, ' style="stroke:rgb(', string(r), ', ', string(g), ', ', string(b), ');stroke-width:2" />');
                end
           end

        case 'dcircle'

            cx = plotData.center(1) * scale + 250;
            cy = 500 - (plotData.center(2) * scale);
    
            radius = plotData.radius * scale;
    
            r = fix(256 * plotData.Color(1));
            g = fix(256 * plotData.Color(2));
            b = fix(256 * plotData.Color(3));

            svgLine = strcat('<circle class="', plotData.title,'" r="', string(radius),'" cx="', string(cx), '" cy="', string(cy));
            svgLine = strcat(svgLine, '" fill="none" stroke-width="2" stroke="rgb(', string(r), ', ', string(g), ', ', string(b), ')" />');
       
        otherwise
            svgLine = "";
    end
end

