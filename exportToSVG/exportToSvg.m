function exp = exportToSvg(g)
    gp = get(g, 'UserData')
    outFile = fopen('export.txt','w');
    
    %for i=1:length(gp.movs)
    %    disp([gp.movs(i)])
        %fprintf(outFile,'%s\n',gp.movs(i).label);
    %end
    
    movables = gp.movs
    fields = fieldnames(movables);
    
    for i=1:numel(fields)
        
        actElem = movables.(fields{i});

        fprintf(outFile,'%s:%s;%f,%f\n', fields{i}, class(actElem), actElem.fig.Position(1), actElem.fig.Position(2));

    end

    dependents = gp.deps
    fields = fieldnames(dependents);
    
    for i=1:numel(fields)

        actElem = dependents.(fields{i});
        
        fprintf(outFile,'%s:%s;%s\n', fields{i}, class(actElem), func2str(actElem.callback));

    end
    
end