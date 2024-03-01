function exp = exportToSvg(g)
    gp = get(g, 'UserData')
    outFile = fopen('export.svg','w');
    list = {};
    
    fprintf(outFile, '<svg xmlns="http://www.w3.org/2000/svg">');

    % classok nem kellenek, jobb egyszerű structokkal

    % cell array kell majd (list = {}, list{1}, list{end+1} = [new elem])

    %<svg xmlns="http://www.w3.org/2000/svg">
    %    <title>henlo</title>
    %    <line x1="0" y1="0" x2="300" y2="200" style="stroke:red;stroke-width:2" />
    %    <circle r="5" cx="200" cy="50" fill="red" />
    %</svg>

    %for i=1:length(gp.movs)
    %    disp([gp.movs(i)])
        %fprintf(outFile,'%s\n',gp.movs(i).label);
    %end
    
    movables = gp.movs
    fields = fieldnames(movables);
    
    for i=1:numel(fields)
        
        actElem = movables.(fields{i});

        %fprintf(outFile,'%s:%s;%f,%f\n', fields{i}, class(actElem), actElem.fig.Position(1), actElem.fig.Position(2));
        fprintf(outFile,'%s\n', TypeMatcher(actElem));
    end

    dependents = gp.deps
    fields = fieldnames(dependents);
    
    for i=1:numel(fields)

        actElem = dependents.(fields{i});
        
        %fprintf(outFile,'%s:%s;%s\n', fields{i}, class(actElem), func2str(actElem.callback));
        fprintf(outFile,'%s\n', TypeMatcher(actElem));

    end

    fprintf(outFile, '</svg>');
    
end