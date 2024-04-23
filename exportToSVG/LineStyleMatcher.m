function svgStyle = LineStyleMatcher(mlStyle)
    switch mlStyle
        case ':'
           svgStyle = ' stroke-dasharray="1, 3"';
        case '--'
            svgStyle = ' stroke-dasharray="10, 7"';
        otherwise
            svgStyle = '';
    end
end