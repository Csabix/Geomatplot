function type = TypeMatcher(plot)

    pFig = plot.fig;
    pClass = class(plot);

    switch pClass
        case 'mpoint'
            
            cx = pFig.Position(1) * 1000;
            cy = pFig.Position(2) * 1000;
            
            r = fix(256 * pFig.Color(1));
            g = fix(256 * pFig.Color(2));
            b = fix(256 * pFig.Color(3));
            
            type = strcat('<circle r="5" cx="', string(cx), '" cy="', string(cy));
            type = strcat(type, '" fill="rgb(', string(r), ', ', string(g), ', ', string(b), ')" />');
        
        case 'dpoint'
            
            cx = pFig.Position(1) * 1000;
            cy = pFig.Position(2) * 1000;
            
            r = fix(256 * pFig.Color(1));
            g = fix(256 * pFig.Color(2));
            b = fix(256 * pFig.Color(3));
            
            type = strcat('<circle r="5" cx="', string(cx), '" cy="', string(cy));
            type = strcat(type, '" fill="rgb(', string(r), ', ', string(g), ', ', string(b), ')" />');
        
        case 'dlines'
            
            x1 = plot.fig.XData(1) * 1000;
            y1 = plot.fig.YData(1) * 1000;

            x2 = plot.fig.XData(2) * 1000;
            y2 = plot.fig.YData(2) * 1000;

            r = fix(256 * pFig.Color(1));
            g = fix(256 * pFig.Color(2));
            b = fix(256 * pFig.Color(3));
            
            type = strcat('<line x1="', string(x1), '" y1="', string(y1), '" x2="', string(x2), '" y2="', string(y2), '"');
            type = strcat(type, ' style="stroke:rgb(', string(r), ', ', string(g), ', ', string(b), ');stroke-width:2" />');
       
        otherwise
            type = "";
    end
end

