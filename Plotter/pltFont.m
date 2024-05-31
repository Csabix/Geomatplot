function pltFont(font, size, bold, italic, plt)
arguments
    font (1,1) string
    size (1,1) = 24
    bold (1,1) logical = false
    italic (1,1) logical = false
    plt (1,1) Plot = cplt(false)
end
    if isempty(plt)
        return
    end

    plt.JPlot.setFont(font, bold, italic, size);
end

