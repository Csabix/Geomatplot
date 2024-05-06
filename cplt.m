function plt = cplt(createIfEmpty)
    arguments
        createIfEmpty (1,1) logical = true;
    end
    global globalPlt;
    if isempty(globalPlt) && createIfEmpty
        globalPlt = Plot;
        globalPlt.setFrameCallback('WindowClosedCallback',@(~,~)clearcplt(globalPlt));
    end
    plt = globalPlt;
end