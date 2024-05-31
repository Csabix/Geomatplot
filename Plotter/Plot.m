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
        figs
    end
    
    methods
        function obj = Plot()
            obj.JPlot = GeomatPlot.Plot;
            obj.JClickInput = obj.JPlot.clickInputQuery;
            obj.FrameH = handle(obj.JPlot.frame,'CallbackProperties');
            obj.CanvasH = handle(obj.JPlot.canvas,'CallbackProperties');
            obj.figs = {};
        end

        function setFrameCallback(obj,name,fcn)
            set(obj.FrameH, name, fcn);
        end

        function setCanvasCallback(obj,name,fcn)
            set(obj.CanvasH, name, fcn);
        end

        function addDrawable(obj,drawable)
            if ~isempty(drawable)
                addDrawable(obj.JPlot,drawable);
            end
        end

        function addDrawables(obj,drawable)
            if ~isempty(drawable)
                addDrawables(obj.JPlot,drawable);
            end
        end

        function updateDrawable(obj,drawable)
            updateDrawable(obj.JPlot,drawable);
        end

        function updateDrawables(obj,drawable)
            if ~isempty(drawable)
                updateDrawables(obj.JPlot,drawable);
            end
        end

        function removeDrawable(obj,drawables)
            for i = 1:numel(drawables)
                removeDrawable(obj.JPlot,drawables(i));
            end
        end

        function removeDrawables(obj,drawables)
            if ~isempty(drawables)
                removeDrawables(obj.JPlot,drawables);
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

        function addFig(obj,fig)
            obj.figs{end+1} = fig;
        end

        function delete(obj)
            for x = obj.figs
                delete(x{1});
            end
        end
    end
end

