classdef LabelH < handle
    properties(Dependent = true)
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

    events
        Moved
    end
    
    methods
        function obj = LabelH(plot, text, position, offset, visible)
            obj.plot = plot;
            obj.gLabel = GeomatPlot.Draw.gLabel(position(1),position(2),text);
            obj.gLabel.oX = offset(1);
            obj.gLabel.oY = offset(2);
            if visible
                addDrawable(obj.plot,obj.gLabel);
            end
            addFig(obj.plot,obj);
        end

        function delete(obj)
            obj.gLabel = [];
            obj.UserData = [];
        end
        
        function position = get.Position(obj)
            position = [obj.gLabel.x,obj.gLabel.y];
        end

        function set.Position(obj,position)
            obj.gLabel.x = position(1);
            obj.gLabel.y = position(2);
            if(obj.gLabel.getID ~= -1)
                updateDrawable(obj.plot,obj.gLabel);
            end
        end

        function offset = get.Offset(obj)
            offset = [obj.gLabel.oX, obj.gLabel.oY];
        end

        function set.Offset(obj, offset)
            obj.gLabel.oX = offset(1);
            obj.gLabel.oY = offset(2);
            if(obj.gLabel.getID ~= -1)
                updateDrawable(obj.plot,obj.gLabel);
            end
        end

        function visible = get.Visible(obj)
            visible = obj.gLabel.getID ~= -1;
        end

        function set.Visible(obj,visible)
            if visible
                addDrawable(obj.plot,obj.gLabel);
            else
                removeDrawable(obj.plot,obj.gLabel);
            end
        end

        function text = get.Text(obj)
            text = obj.Text;
        end

        function set.Text(obj, text)
            newLabel = Geomatplot.Draw.gLabel(obj.gLabel.x,obj.gLabel.y,text);
            if obj.gLabel.getID ~= -1
                addDrawable(obj.plot,newLabel);
                removeDrawable(obj.plot,obj.gLabel);
            end
            obj.gLabel = newLabel;
        end
    end
end

