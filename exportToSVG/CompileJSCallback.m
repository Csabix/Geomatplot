function returnFunction = CompileJSCallback(callback ,inputs, plot)
args = GetArguements(callback);
% https://www.mathworks.com/help/matlab/matlab_prog/operator-precedence.html
    %if contains(callback, '.value')

    %elseif contains(callback, '[') && contains(callback, ']')
    if contains(callback, ".'") || contains(callback, ".^") || contains(callback, "'") || contains(callback, "^")

    end
end

