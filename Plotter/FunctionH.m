classdef FunctionH < handle
    properties
        gFunction
        plot Plot
        UserData
    end

    properties(Dependent)
        Visible
    end
    
    methods
        function obj = FunctionH(plot, location, resolution)
            switch resolution
                case 0
                    res=javaMethod('valueOf','GeomatPlot.Draw.FunctionDrawer$Resolution','QUARTER');
                case 1
                    res=javaMethod('valueOf','GeomatPlot.Draw.FunctionDrawer$Resolution','HALF');
                case 2
                    res=javaMethod('valueOf','GeomatPlot.Draw.FunctionDrawer$Resolution','MATCHING');
                case 3
                    res=javaMethod('valueOf','GeomatPlot.Draw.FunctionDrawer$Resolution','DOUBLE');
                otherwise
                    res=javaMethod('valueOf','GeomatPlot.Draw.FunctionDrawer$Resolution','MATCHING');
            end
            obj.gFunction = GeomatPlot.Draw.gFunction(location, res);
            obj.plot = plot;
            addDrawable(obj.plot,obj.gFunction);
            addFig(obj.plot,obj);
        end

        function delete(obj)
            obj.gFunction = [];
            obj.UserData = [];
        end

        function visible = get.Visible(obj)
            visible = obj.gFunction.getID ~= -1;
        end

        function set.Visible(obj, visible)
            if visible
                addDrawable(obj.plot,obj.gFunction);
            else
                removeDrawable(obj.plot,obj.gFunction);
            end
        end
    end
end

