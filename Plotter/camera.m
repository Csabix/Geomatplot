function camera(x, y, plt)
    arguments
        x (1,1)
        y (1,1)
        plt (1,1) Plot = cplt
    end
    setX(plt.JPlot.camera,x);
    setY(plt.JPlot.camera,y);
    %plt.JPlot.camera.setX(x);
    %plt.JPlot.camera.setY(y);
end