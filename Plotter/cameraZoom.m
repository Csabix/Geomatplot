function cameraZoom(zoomVal, plt)
    arguments
        zoomVal (1,1)
        plt (1,1) Plot = cplt
    end
    if(zoomVal <= 0)
        zoomVal = 1;
    end
    setZoom(plt.JPlot.camera,zoomVal);
end