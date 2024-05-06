function color = parseColor(colorIn)
    colorIn = convertStringsToChars(colorIn);
    color = zeros(numel(colorIn),3);
    for i = 1:numel(colorIn)
        c = colorIn(i);
        switch c
            case 'r'
                color(i,:) = [1 0 0];
            case 'g'
                color(i,:) = [0 1 0];
            case 'b'
                color(i,:) = [0 0 1];
            case 'c'
                color(i,:) = [0 1 1];
            case 'm'
                color(i,:) = [1 0 1];
            case 'y'
                color(i,:) = [1 1 0];
            case 'k'
                color(i,:) = [0 0 0];
            case 'w'
                color(i,:) = [1 1 1];
        end
    end
end

