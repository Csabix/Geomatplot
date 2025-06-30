classdef DistanceSlot < handle
    properties
        geoLabel
        distLabel
        distHandle
    end
    
    methods(Access=public)
        function o = DistanceSlot(parentList,distHandle)
            panel = uipanel(parentList);
            panel.UserData = o;
            o.distHandle = distHandle;

            layout = uigridlayout(panel);
            layout.RowHeight = {'1x' '1x'};
            layout.ColumnWidth = {'1x'};
            layout.Padding = [0 0 0 0];
            layout.RowSpacing = 1;

            topLayout = uigridlayout(layout);
            topLayout.Layout.Row = 1;
            topLayout.RowHeight = {'1x'};
            topLayout.ColumnWidth = {'1x'};
            topLayout.Padding = [0 0 0 0];
            topLayout.ColumnSpacing = 1;

            o.geoLabel = uilabel(topLayout);
            o.geoLabel.HorizontalAlignment = 'center';
            o.geoLabel.Layout.Column = 1;
            o.updateText();

            botLayout = uigridlayout(layout);
            botLayout.Layout.Row = 2;
            botLayout.RowHeight = {'1x'};
            botLayout.ColumnWidth = {'3x' '3x' '1x'};
            botLayout.Padding = [0 0 0 0];
            botLayout.ColumnSpacing = 1;

            o.distLabel = uieditfield(botLayout,'text');
            o.distLabel.Layout.Column = 1;
            o.distLabel.Value = o.distHandle.label;
            o.distLabel.ValueChangedFcn = @(src,evt) o.editLabelChanged(src,evt);

            selLabel = uibutton(botLayout);
            selLabel.Layout.Column = 3;
            selLabel.HorizontalAlignment = 'center';
            selLabel.Text = 'S';
            selLabel.Tooltip = 'Click to select distance for geometries.';
            selLabel.ButtonPushedFcn = @(src,evt) o.selectDistance(src,evt);
        end
        
        function updateText(o)
            o.geoLabel.Text = "Distance(" + o.distHandle.inputs{1}.label ...
                + "," + o.distHandle.inputs{2}.label + ")";
        end
    end % public

    methods(Access=private)
        function editLabelChanged(o,src,evt)
            if ~Utils.renameLabel(o.distHandle,evt.Value)
                src.Value = o.distHandle.label;
            end
        end

        function selectDistance(o,~,~)
            go = o.distHandle.parent;
            go.pushData(o.distHandle);
        end
    end % private
end

