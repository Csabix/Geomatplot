classdef ScalarSlot < handle
    properties
        minText
        maxText
        slider
        currentValueText
        labelText
        value
        scalarHandle
    end
    
    methods(Access=public)
        function o = ScalarSlot(Geomatplot,parentList)
            panel = uipanel(parentList);
            limits = [-5 5];
            o.value = sum(limits)/2;
            o.scalarHandle = Scalar(Geomatplot,@() ScalarSlot.slidercallb(o));

            layout = uigridlayout(panel);
            layout.RowHeight = {'1x' '1x'};
            layout.ColumnWidth = {'1x'};
            layout.Padding = [0 0 0 0];
            layout.RowSpacing = 1;

            topLayout = uigridlayout(layout);
            topLayout.Layout.Row = 1;
            topLayout.RowHeight = {'1x'};
            topLayout.ColumnWidth = {'3x' '1x' '3x'};
            topLayout.Padding = [0 0 0 0];
            topLayout.ColumnSpacing = 1;

            o.labelText = uieditfield(topLayout,'text');
            o.labelText.Layout.Column = 1;
            o.labelText.Value = o.scalarHandle.label;
            o.labelText.ValueChangedFcn = @(src,evt) o.editLabelChanged(src,evt);

            eqLabel = uibutton(topLayout);
            eqLabel.Layout.Column = 2;
            eqLabel.HorizontalAlignment = 'center';
            eqLabel.Text = '=';
            eqLabel.Tooltip = 'Click to select scalar for geometries.';
            eqLabel.ButtonPushedFcn = @(src,evt) o.selectScalar(src,evt);

            o.currentValueText = uieditfield(topLayout,'numeric');
            o.currentValueText.Layout.Column = 3;
            o.currentValueText.Limits = limits;
            o.currentValueText.Value = o.value;
            o.currentValueText.ValueChangedFcn = @(src,evt) o.editValueChanged(evt);

            botLayout = uigridlayout(layout);
            botLayout.Layout.Row = 2;
            botLayout.RowHeight = {'1x'};
            botLayout.ColumnWidth = {'1x' '3x' '1x'};
            botLayout.Padding = [0 0 0 0];
            botLayout.ColumnSpacing = 1;

            o.minText = uilabel(botLayout);
            o.minText.HorizontalAlignment = 'center';
            o.minText.Layout.Column = 1;
            o.minText.Text = num2str(limits(1));

            o.slider = uislider(botLayout);
            o.slider.Layout.Column = 2;
            o.slider.Limits = limits;
            o.slider.MajorTicks = [];
            o.slider.MinorTicks = [];
            o.slider.Value = o.value;
            o.slider.ValueChangingFcn = @(src,evt) o.sliderValueChanged(evt);

            o.maxText = uilabel(botLayout);
            o.maxText.HorizontalAlignment = 'center';
            o.maxText.Layout.Column = 3;
            o.maxText.Text = num2str(limits(2));
        end
        
    end % public

    methods(Access=private)
        function editValueChanged(o,evt)
            o.updateValue(evt.Value);
            o.slider.Value = o.value;
        end

        function sliderValueChanged(o,evt)
            o.updateValue(evt.Value);
            o.currentValueText.Value = o.value;
        end

        function editLabelChanged(o,src,evt)
            if ~PropertiesPanel.renameLabel(o.scalarHandle,evt.Value)
                src.Value = o.scalarHandle.label;
            end
        end

        function updateValue(o,value)
            o.value = value;
            o.scalarHandle.update();
        end

        function selectScalar(o,~,~)
            go = o.scalarHandle.parent;
            go.pushData(o.scalarHandle);
        end
    end % private

    methods(Access=private,Static)
        function v = slidercallb(o)
            v = o.value;
        end
    end % static private
end

