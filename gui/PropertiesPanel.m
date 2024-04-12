classdef PropertiesPanel < handle
    %PANELS Create panels for the app
    properties (Access = private)
        propertiesPanel
        labelPanel
        geometry
    end

    methods (Access = public)
        function o = PropertiesPanel(fig,pos,geometry)
            if isa(geometry,'point_base')
                o = createPointPanel(o,fig,pos,geometry);
            elseif isa(geometry,'dlines')
                o = createLinePanel(o,fig,pos,geometry);
            end
        end

        function delete(o)
            delete(o.propertiesPanel);
            delete(o.labelPanel);
        end
    end

    methods(Access = private)
        function o = createPointPanel(o,fig,pos,geometry)
            o.geometry = geometry;
            propPanel = uipanel(fig);
            propPanel.Position = [pos + [10 -50], 80, 35];
            o.propertiesPanel = propPanel;

            grid = PropertiesPanel.createContainerGrid(propPanel,{{25},{25 25}},[5 5 5 5]);
            addlistener (grid, 'ButtonDown', @(~,~) PropertiesPanel.closeSubPanels(o));
            PropertiesPanel.createColorDropdown(o,grid,[1 1]);
    
            labelButton = uibutton(grid);
            labelButton.Layout.Row = 1;
            labelButton.Layout.Column = 2;
            labelButton.Tooltip = "Label";
            labelButton.Text = "";
            labelButton.Icon = imread("gui\resources\Label.png");
            labelButton.ButtonPushedFcn = @(src,evt) PropertiesPanel.switchLabelPanel(o,src,evt);
        end

        function o = createLinePanel(o,fig,pos,geometry)
            o.geometry = geometry;
            propPanel = uipanel(fig);
            propPanel.Position = [pos + [10 -50], 70, 35];
            o.propertiesPanel = propPanel;

            grid = PropertiesPanel.createContainerGrid(propPanel,{{25}, {25 25}},[5 5 5 5]);
            PropertiesPanel.createColorDropdown(o,grid,[1 1]);  

            styles = {'-','--',':','-.'};
            icons = {'gui/resources/LinestyleSolid.png'
                     'gui/resources/LinestyleDashed.png'
                     'gui/resources/LinestyleDotted.png'
                     'gui/resources/LinestyleDashdotted.png'
                    };
            styleDropdown = uidropdown(grid);
            styleDropdown.ValueChangedFcn = @(src,evt) PropertiesPanel.setLinestyle(o,src,evt);
            styleDropdown.Layout.Row = 1;
            styleDropdown.Layout.Column = 2;
            styleDropdown.Items = repmat({''}, numel(styles), 1);
            styleDropdown.ItemsData = styles;
            styleDropdown.Tooltip = "Linestyle";
            for i = 1:numel(styles)
                style = uistyle('Icon',icons{i});
                addStyle(styleDropdown,style,"item",i);
            end
            styleDropdown.Value = geometry.fig.LineStyle;
        end
    end

    methods (Access = private,Static)
        function createColorDropdown(o,grid,layout)
            colors = {[1 0 0], [0 1 0], [0 0 1], [0 0 0]};
            colorDropdown = uidropdown(grid);
            colorDropdown.ValueChangedFcn = @(src,evt) PropertiesPanel.setColor(o,src,evt);
            colorDropdown.Layout.Row = layout(1);
            colorDropdown.Layout.Column = layout(2);
            colorDropdown.Items = repmat({''}, numel(colors), 1);
            colorDropdown.ItemsData = colors;
            colorDropdown.Tooltip = "Color";
            addlistener (colorDropdown, 'DropDownOpening', @(~,~) PropertiesPanel.closeSubPanels(o));
            for i = 1:numel(colors)
                style = uistyle('BackgroundColor',colors{i});
                addStyle(colorDropdown,style,"item",i);
            end
            %Setting it directly could be a problem if the color is not in
            %the list
            colorDropdown.Value = o.geometry.fig.Color;
        end

        function createLabelPanel(o)
            labelPanel = uipanel(o.propertiesPanel.Parent);
            labelPanel.Position = [o.propertiesPanel.Position(1:2) + [40 -75], 90, 70];
            o.labelPanel = labelPanel;

            grid = PropertiesPanel.createContainerGrid(labelPanel,{{25 25}, {35 35}},[5 5 5 5]);
                
            label = uilabel(grid);
            label.Layout.Row = 1;
            label.Layout.Column = 1;

            editField = uieditfield(grid, 'text');
            editField.Layout.Row = 1;
            editField.Layout.Column = 2;
            editField.Tooltip = "Label";
            editField.Value = o.geometry.label;
            editField.ValueChangedFcn = @(src,evt) PropertiesPanel.setLabel(o,src,evt);

            showLabel = uilabel(grid);
            showLabel.Layout.Row = 2;
            showLabel.Layout.Column = 1;
            showLabel.Text = "Show";

            showCheckbox = uicheckbox(grid);
            showCheckbox.Layout.Row = 2;
            showCheckbox.Layout.Column = 2;
            showCheckbox.Text = "";
            showCheckbox.Value = strcmp(o.geometry.fig.LabelVisible,'on');
            showCheckbox.ValueChangedFcn = @(src,evt) PropertiesPanel.switchLabel(o,src,evt);
        end

        function grid = createContainerGrid(panel,size,padding)
            grid = uigridlayout(panel);
            grid.RowHeight = size{1};
            grid.ColumnWidth = size{2};
            grid.Padding = padding;
        end

        function setColor(o,~,evt)
            o.geometry.fig.Color = evt.Value;
        end

        function setLinestyle(o,~,evt)
            o.fig.LineStyle = evt.Value;
        end

        function setLabel(o,~,evt)
            newLabel = evt.Value;
            oldLabel = o.geometry.label;
            go = o.geometry.parent;
            if go.isLabel(newLabel)
                %Needs better response
                disp("Label already exists!");
            else
                PropertiesPanel.changeGeomatplotLabel(go,oldLabel,newLabel);
                o.geometry.fig.Label = newLabel;
                o.geometry.label = newLabel;
            end
        end

        function changeGeomatplotLabel(Geomatplot,oldLabel,newLabel)
            if isfield(Geomatplot.movs,oldLabel)
                Geomatplot.movs = PropertiesPanel.renameField(Geomatplot.movs,oldLabel,newLabel);
            elseif isfield(Geomatplot.deps,oldLabel)
                Geomatplot.deps = PropertiesPanel.renameField(Geomatplot.deps,oldLabel,newLabel);
            end
        end

        function struct = renameField(struct,oldLabel,newLabel)
            struct.(newLabel) = struct.(oldLabel);
            struct = rmfield(struct, oldLabel);
        end

        function switchLabel(o,~,evt)
            o.geometry.fig.LabelVisible = string(matlab.lang.OnOffSwitchState(evt.Value));
        end

        function closeSubPanels(o)
            if ~isempty(o.labelPanel); delete(o.labelPanel); o.labelPanel = []; end
        end

        function switchLabelPanel(o,~,~)
            %Should close other sub panels later
            if isempty(o.labelPanel); PropertiesPanel.createLabelPanel(o);
            else; delete(o.labelPanel); o.labelPanel = []; end
        end
    end
end