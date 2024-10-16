classdef ScalarSlot < handle
    properties
        slider
        currentValueText
        labelText
        Pt
        val
        txt
    end
    
    methods(Access=public)
        function o = ScalarSlot(parentList,val)
            panel = uipanel(parentList);
            o.Pt = val.inputs{1};
            depFields = fieldnames(o.Pt.deps);
            for i = 1:length(depFields)
                dep = o.Pt.deps.(depFields{i});
                if isa(dep,'dtext')
                    o.txt = dep;
                    break;
                end
            end
            o.val = val;
            usercallback = functions(functions(val.callback).workspace{1}.usercallback);
            limits = usercallback.workspace{1}.args.range;

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
            o.labelText.Value = o.Pt.label;
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
            o.currentValueText.Value = o.val.val;
            o.currentValueText.ValueChangedFcn = @(src,evt) o.editValueChanged(evt);

            botLayout = uigridlayout(layout);
            botLayout.Layout.Row = 2;
            botLayout.RowHeight = {'1x'};
            botLayout.ColumnWidth = {'1x' '3x' '1x'};
            botLayout.Padding = [0 0 0 0];
            botLayout.ColumnSpacing = 1;

            minText = uilabel(botLayout);
            minText.Text = num2str(limits(1));

            o.slider = uislider(botLayout);
            o.slider.Limits = limits;
            o.slider.MajorTicks = [];
            o.slider.MinorTicks = [];
            o.slider.Value = o.val.val;
            o.slider.ValueChangingFcn = @(src,evt) o.sliderValueChanged(evt);

            maxText = uilabel(botLayout);
            maxText.Text = num2str(limits(2));
        end
        
    end % public

    methods(Access=private)
        function editValueChanged(o,evt)
            o.updateValue(evt.Value);
            o.slider.Value = evt.Value;
        end
        
        function sliderValueChanged(o,evt)
            o.updateValue(evt.Value);
            o.currentValueText.Value = evt.Value;
        end

        function editLabelChanged(o,src,evt)
            if ~Utils.renameLabel(o.Pt,evt.Value)
                src.Value = o.Pt.label;
            else
                o.Pt.static_update(o.Pt.fig,struct('EventName', 'ROIMoved'));
            end
        end

        function updateValue(o,value)
            startPos = o.Pt.inputs{2}.inputs{1}.fig.Position;
            slideLen = o.Pt.inputs{2}.inputs{2}.fig.Position - startPos;
            range = o.currentValueText.Limits;
            pos = startPos + [slideLen(1) * ((value - range(1))/diff(range)),0];
            o.Pt.updatePlot(pos);
            o.Pt.static_update(o.Pt.fig,struct('EventName', 'ROIMoved'));
        end

        function selectScalar(o,~,~)
            go = o.val.parent;
            go.pushData(o.val);
        end
    end % private

    methods(Access=private,Static)
        function v = slidercallb(o)
            v = o.value;
        end
    end % static private
end

