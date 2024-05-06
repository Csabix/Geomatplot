classdef labelH < handle
    properties(Dependent = true, SetObservable=true)
        Position,
        Text,
        Offset,
        Visible
    end

    properties
        gLabel
        plot Plot
        UserData
    end
    
    methods
        function obj = labelH(plot, text, varargin)
            obj.plot = plot;
            if(length(varargin) == 1)
                pos = varargin{1};
                obj.gLabel = GeomatPlot.Draw.gLabel(pos(1),pos(2),text);
            else
                obj.gLabel = GeomatPlot.Draw.gLabel(0,0,text);
            end
            plot.addDrawable(obj.gLabel);
        end
        
        function position = get.Position(obj)
            position = [obj.gLabel.x,obj.gLabel.y];
        end

        function set.Position(obj,position)
            obj.gLabel.x = position(1);
            obj.gLabel.y = position(2);
            if(obj.gLabel.getID ~= -1)
                obj.plot.updateDrawable(obj.gLabel);
            end
        end

        function offset = get.Offset(obj)
            offset = [obj.gLabel.oX, obj.gLabel.oY];
        end

        function set.Offset(obj, offset)
            obj.gLabel.oX = offset(1);
            obj.gLabel.oY = offset(2);
            if(obj.gLabel.getID ~= -1)
                obj.plot.updateDrawable(obj.gLabel);
            end
        end

        function visible = get.Visible(obj)
            visible = obj.gLabel.getID ~= -1;
        end

        function set.Visible(obj,visible)
            if visible
                obj.plot.addDrawable(obj.gLabel);
            else
                obj.plot.removeDrawable(obj.gLabel);
            end
        end

        function text = get.Text(obj)
            text = obj.Text;
        end

        function set.Text(obj, text)
            newLabel = Geomatplot.Draw.gLabel(obj.gLabel.x,obj.gLabel.y,text);
            if obj.gLabel.getID ~= -1
                obj.plot.addDrawable(newLabel);
                obj.plot.removeDrawable(obj.gLabel);
            end
            obj.gLabel = newLabel;
        end
    end
end

