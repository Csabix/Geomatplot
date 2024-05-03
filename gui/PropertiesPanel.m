classdef PropertiesPanel < handle
    %PANELS Create panels for the app
    properties (Access = private)
        propPanel
        geometry
    end

    methods (Access = public)
        function o = PropertiesPanel(fig,pos,geometry)
            if isa(geometry,'point_base')
                o = createPointPanel(o,fig,pos,geometry);
            elseif isa(geometry,'dlines')
                o = createLinePanel(o,fig,pos,geometry);
            elseif isa(geometry,'polygon_base')
                o = createPolygonPanel(o,fig,pos,geometry);
            end
        end

        function delete(o)
            o.closeSubPanels();
            delete(o.propPanel);
        end
    end % public

    methods(Access = private)
        function o = createPointPanel(o,fig,pos,geometry)
            o.geometry = geometry;
            o.propPanel = uipanel(fig);
            o.propPanel.Position = [pos + [10 -50], 105, 35];

            grid = PropertiesPanel.createContainerGrid(o.propPanel,{{25},{25 25 25}},[5 5 5 5]);
            addlistener (grid, 'ButtonDown', @(~,~) o.closeSubPanels);
            colorDropdown = o.createColorDropdown(grid,[1 1],@(src,evt) o.setColor(evt),"Color");
            colorDropdown.Value = o.geometry.fig.Color;

            labelButton = uibutton(grid);
            labelButton.Layout.Row = 1;
            labelButton.Layout.Column = 2;
            labelButton.Tooltip = "Label";
            labelButton.Text = "";
            labelButton.Icon = imread("gui\resources\Label.png");
            labelButton.ButtonPushedFcn = @(~,~) o.switchLabelPanel;

            size = geometry.fig.MarkerSize - 2;
            markerButton = uibutton(grid);
            markerButton.Layout.Row = 1;
            markerButton.Layout.Column = 3;
            markerButton.Tooltip = "Marker";
            markerButton.Text = "";
            markerButton.Icon = imread("gui\resources\Marker.png");
            markerButton.ButtonPushedFcn = @(~,~) o.switchMarkerPanel(size,[1 10]);
        end

        function o = createLinePanel(o,fig,pos,geometry)
            o.geometry = geometry;
            o.propPanel = uipanel(fig);
            o.propPanel.Position = [pos + [10 -50], 105, 35];

            grid = PropertiesPanel.createContainerGrid(o.propPanel,{{25}, {25 25 25}},[5 5 5 5]);
            addlistener (grid, 'ButtonDown', @(~,~) o.closeSubPanels);
            colorDropdown = o.createColorDropdown(grid,[1 1],@(src,evt) o.setColor(evt),"Color");  
            colorDropdown.Value = o.geometry.fig.Color;

            o.createLinestyleDropdown(grid,[1 2]);

            size = geometry.fig.LineWidth - 1;
            markerButton = uibutton(grid);
            markerButton.Layout.Row = 1;
            markerButton.Layout.Column = 3;
            markerButton.Tooltip = "Marker";
            markerButton.Text = "M";
            markerButton.ButtonPushedFcn = @(~,~) o.switchMarkerPanel(size,[1 5]);
        end

        function o = createPolygonPanel(o,fig,pos,geometry)
            o.geometry = geometry;
            o.propPanel = uipanel(fig);
            o.propPanel.Position = [pos + [10 -50], 105, 35];

            grid = PropertiesPanel.createContainerGrid(o.propPanel,{{25}, {25 25 25}},[5 5 5 5]);
            addlistener (grid, 'ButtonDown', @(~,~) o.closeSubPanels);
            colorDropdown = o.createColorDropdown(grid,[1 1],@(src,evt) o.setFaceColor(evt),"Face color");
            colorDropdown.Value = o.geometry.fig.FaceColor;

            o.createLinestyleDropdown(grid,[1 2]);

            lineColorDropdown = o.createColorDropdown(grid,[1 3],@(src,evt) o.setEdgeColor(evt),"Line color");
            lineColorDropdown.Value = o.geometry.fig.EdgeColor;
        end
    
        function colorDropdown = createColorDropdown(o,grid,layout,valueChangedFcn,tooltip)
            colors = {[1 0 0], [0 1 0], [0 0 1], [0 0 0]};
            colorDropdown = uidropdown(grid);
            colorDropdown.ValueChangedFcn = valueChangedFcn;
            colorDropdown.Layout.Row = layout(1);
            colorDropdown.Layout.Column = layout(2);
            colorDropdown.Items = repmat({''}, numel(colors), 1);
            colorDropdown.ItemsData = colors;
            colorDropdown.Tooltip = tooltip;
            addlistener (colorDropdown, 'DropDownOpening', @(~,~) o.closeSubPanels);
            for i = 1:numel(colors)
                style = uistyle('BackgroundColor',colors{i});
                addStyle(colorDropdown,style,"item",i);
            end
        end

        function createLinestyleDropdown(o,grid,layout)
            styles = {'-','--',':','-.'};
            icons = {'gui/resources/LinestyleSolid.png'
                     'gui/resources/LinestyleDashed.png'
                     'gui/resources/LinestyleDotted.png'
                     'gui/resources/LinestyleDashdotted.png'
                    };
            styleDropdown = uidropdown(grid);
            styleDropdown.ValueChangedFcn = @(src,evt) o.setLinestyle(evt);
            styleDropdown.Layout.Row = layout(1);
            styleDropdown.Layout.Column = layout(2);
            styleDropdown.Items = repmat({''}, numel(styles), 1);
            styleDropdown.ItemsData = styles;
            styleDropdown.Tooltip = "Linestyle";
            addlistener (styleDropdown, 'DropDownOpening', @(~,~) o.closeSubPanels);
            for i = 1:numel(styles)
                style = uistyle('Icon',icons{i});
                addStyle(styleDropdown,style,"item",i);
            end
            styleDropdown.Value = o.geometry.fig.LineStyle;
        end

        function closeSubPanels(o)
            if isempty(o.propPanel); return; end

            children = o.propPanel.Parent.Children;
            for i = 1:length(children)
                child = children(i);
                if isa(child,'matlab.ui.container.Panel') && ~isempty(child.UserData)
                    delete(child);
                end
            end
        end

        function panel = findSubPanel(o,subpanelName,removeOthers)
            panel = [];
            children = o.propPanel.Parent.Children;
            for i = 1:length(children)
                child = children(i);
                if isa(child,'matlab.ui.container.Panel') && ~isempty(child.UserData)
                    if strcmp(child.UserData{2},subpanelName); panel = child;
                    elseif removeOthers; delete(child); end
                end
            end
        end

        function createLabelPanel(o)
            labelPanel = uipanel(o.propPanel.Parent);
            labelPanel.Position = [o.propPanel.Position(1:2) + [40 -75], 90, 70];
            labelPanel.UserData = {'subpanel','label'};

            grid = PropertiesPanel.createContainerGrid(labelPanel,{{25 25}, {35 35}},[5 5 5 5]);
                
            label = uilabel(grid);
            label.Layout.Row = 1;
            label.Layout.Column = 1;

            editField = uieditfield(grid, 'text');
            editField.Layout.Row = 1;
            editField.Layout.Column = 2;
            editField.Tooltip = "Label";
            editField.Value = o.geometry.label;
            editField.ValueChangedFcn = @(src,evt) o.setLabel(src,evt);

            showLabel = uilabel(grid);
            showLabel.Layout.Row = 2;
            showLabel.Layout.Column = 1;
            showLabel.Text = "Show";

            showCheckbox = uicheckbox(grid);
            showCheckbox.Layout.Row = 2;
            showCheckbox.Layout.Column = 2;
            showCheckbox.Text = "";
            showCheckbox.Value = strcmp(o.geometry.fig.LabelVisible,'on');
            showCheckbox.ValueChangedFcn = @(src,evt) o.setLabelVisibility(evt);
        end

        function createMarkerPanel(o,size,limits)
            markerPanel = uipanel(o.propPanel.Parent);
            markerPanel.Position = [o.propPanel.Position(1:2) + [75 -40], 105, 35];
            markerPanel.UserData = {'subpanel','marker'};

            grid = PropertiesPanel.createContainerGrid(markerPanel,{{25}, {70, 25}},[5 5 5 5]);
            
            markerSize = uislider(grid);
            markerSize.Layout.Row = 1;
            markerSize.Layout.Column = 1;
            markerSize.Limits = limits;
            markerSize.MajorTicks = [];
            markerSize.MinorTicks = [];
            markerSize.Value = size;
            markerSize.ValueChangingFcn = @(src,evt) o.setMarkerSize(evt);

            markerSizeLabel = uilabel(grid);
            markerSizeLabel.Layout.Row = 1;
            markerSizeLabel.Layout.Column = 2;
            markerSizeLabel.Text = string(size);
        end

        function switchLabelPanel(o)
            labelPanel = o.findSubPanel('label',true);

            if isempty(labelPanel); o.createLabelPanel();
            else; delete(labelPanel); end
        end

        function switchMarkerPanel(o,size,limits)
            markerPanel = o.findSubPanel('marker',true);

            if isempty(markerPanel); o.createMarkerPanel(size,limits);
            else; delete(markerPanel); end
        end

        function setFaceColor(o,evt)
            o.geometry.fig.FaceColor = evt.Value;
        end

        function setEdgeColor(o,evt)
            o.geometry.fig.EdgeColor = evt.Value;
        end

        function setColor(o,evt)
            o.geometry.fig.Color = evt.Value;
        end

        function setLinestyle(o,evt)
            o.geometry.fig.LineStyle = evt.Value;
        end

        function setLabel(o,src,evt)
            if ~Utils.renameLabel(o.geometry,evt.Value)
                src.Value = o.geometry.label;
            end
        end

        function setMarkerSize(o,evt)
            size = floor(evt.Value);
            markerPanel = o.findSubPanel('marker',false);
            markerSizeLabel = markerPanel.Children(1).Children(2);
            markerSizeLabel.Text = string(size);
            if isa(o.geometry,'point_base'); o.geometry.fig.MarkerSize = size + 2;
            elseif isa(o.geometry,'dlines'); o.geometry.fig.LineWidth = size + 1; end
        end

        function setLabelVisibility(o,evt)
            o.geometry.fig.LabelVisible = string(matlab.lang.OnOffSwitchState(evt.Value));
        end
    end % private

    methods (Access = private,Static)
        function grid = createContainerGrid(panel,size,padding)
            grid = uigridlayout(panel);
            grid.RowHeight = size{1};
            grid.ColumnWidth = size{2};
            grid.Padding = padding;
        end
    end % static private
end