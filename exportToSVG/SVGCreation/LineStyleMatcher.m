function svgStyle = LineStyleMatcher(mlStyle, dashedEnabled, dottedEnabled)
    if isequal(mlStyle, ':') && dottedEnabled
        svgStyle = ' stroke-dasharray="1, 3"';
    elseif isequal(mlStyle, '--') && dashedEnabled
        svgStyle = ' stroke-dasharray="10, 7"';
    else
        svgStyle = '';
    end
end