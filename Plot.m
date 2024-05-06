classdef Plot < handle
    properties (SetAccess = immutable)
        JPlot
        JClickInput
    end
    properties
        UserData
    end

    properties (Access=private)
        FrameH
        CanvasH
    end
    
    methods
        function obj = Plot()
            obj.JPlot = GeomatPlot.Plot;
            obj.JClickInput = obj.JPlot.clickInputQuery;
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

        function removeDrawable(obj,drawables)
            for i = 1:numel(drawables)
                obj.JPlot.removeDrawable(drawables(i));
            end
        end

        function p = clickInput(obj)
            p = obj.JPlot.clickInput;
            p = p';
        end

        function p = getInput(obj, condition)
            arguments
                obj
                condition = @(x) true
            end

            obj.JClickInput.getInput;
            while(~condition(obj.JClickInput))
                obj.JClickInput.getInput;
            end

            p = obj.JClickInput.xy;
            p = p';
        end
    end
end

