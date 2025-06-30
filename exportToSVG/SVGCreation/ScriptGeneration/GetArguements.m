function args = GetArguements(callback, inputs)
args = cell(size(inputs));
argStart = 0;
argEnd = 0;
i=1; % index of character being evaluated
j=1; % index of arg being built
while i<numel(callback) && ~isequal(callback(i), ')')
    
    if ~isequal(argStart, 0) && ~isequal(callback(i), ',')
        args{j} = strcat(args{j}, callback(i));
    elseif ~isequal(argStart, 0) && isequal(callback(i), ',')
        j = j + 1;
    end
    
    if isequal(callback(i), '(')
        argStart=i;
    end
    i = i + 1;
end
argEnd = i;
callback = erase(callback, callback(1:argEnd));
end

