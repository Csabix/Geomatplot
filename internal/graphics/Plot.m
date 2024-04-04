classdef Plot < handle
    properties
        JPlot
        UserData
    end

    properties (Access=private)
        FrameH
        CanvasH
    end
    
    methods
        function obj = Plot()
            obj.JPlot = GeomatPlot.Plot;
            obj.FrameH = handle(obj.JPlot.frame,'CallbackProperties');
            obj.CanvasH = handle(obj.JPlot.canvas,'CallbackProperties');
        end

        function setFrameCallback(obj,name,fcn)
            set(obj.FrameH, name,fcn);
        end

        function setCanvasCallback(obj,name,fcn)
            set(obj.CanvasH, name,fcn);
        end

        function addDrawable(obj,drawable)
            obj.JPlot.addDrawable(drawable);
        end

        function updateDrawable(obj,drawable)
            obj.JPlot.updateDrawable(drawable);
        end

        function p = clickInput(obj)
            p = obj.JPlot.clickInput;
            p = p';
        end
    end
end

