function func = drawFunction(location,resolution,plt)
    arguments
        location string
        resolution = 2
        plt = cplt
    end

    func = FunctionH(plt,location,resolution);
end