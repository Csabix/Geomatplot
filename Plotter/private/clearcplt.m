function clearcplt(plot)
    global globalPlt;
    if plot == globalPlt
        globalPlt = [];
    end
    delete(plot);
end

