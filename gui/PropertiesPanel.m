classdef PropertiesPanel < handle
    %PANELS Create panels for the app
    properties (Access = private)
        propertiesPanel
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
            delete(o.propertiesPanel);
        end
    end

    methods(Access = private)
        function o = createPointPanel(o,fig,pos,geometry)
            o.geometry = geometry;
            propPanel = uipanel(fig);
            propPanel.Position = [pos + [10 -50], 105, 35];
            o.propertiesPanel = propPanel;

            grid = PropertiesPanel.createContainerGrid(propPanel,{{25},{25 25 25}},[5 5 5 5]);
            addlistener (grid, 'ButtonDown', @(~,~) o.closeSubPanels);
            colorDropdown = o.createColorDropdown(grid,[1 1],@(src,evt) PropertiesPanel.setColor(o,evt));
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
            propPanel = uipanel(fig);
            propPanel.Position = [pos + [10 -50], 105, 35];
            o.propertiesPanel = propPanel;

            grid = PropertiesPanel.createContainerGrid(propPanel,{{25}, {25 25 25}},[5 5 5 5]);
            addlistener (grid, 'ButtonDown', @(~,~) o.closeSubPanels);
            colorDropdown = o.createColorDropdown(grid,[1 1],@(src,evt) PropertiesPanel.setColor(o,evt));  
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
            propPanel = uipanel(fig);
            propPanel.Position = [pos + [10 -50], 75, 35];
            o.propertiesPanel = propPanel;

            grid = PropertiesPanel.createContainerGrid(propPanel,{{25}, {25 25}},[5 5 5 5]);
            addlistener (grid, 'ButtonDown', @(~,~) o.closeSubPanels);
            colorDropdown = o.createColorDropdown(grid,[1 1],@(src,evt) PropertiesPanel.setFaceColor(o,evt));
            colorDropdown.Value = o.geometry.fig.FaceColor;

            o.createLinestyleDropdown(grid,[1 2]);
        end
    end
    
    methods (Access = private)
        function colorDropdown = createColorDropdown(o,grid,layout,valueChangedFcn)
            colors = {[1 0 0], [0 1 0], [0 0 1], [0 0 0]};
            colorDropdown = uidropdown(grid);
            colorDropdown.ValueChangedFcn = valueChangedFcn;
            colorDropdown.Layout.Row = layout(1);
            colorDropdown.Layout.Column = layout(2);
            colorDropdown.Items = repmat({''}, numel(colors), 1);
            colorDropdown.ItemsData = colors;
            colorDropdown.Tooltip = "Color";
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
            styleDropdown.ValueChangedFcn = @(src,evt) PropertiesPanel.setLinestyle(o,evt);
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
            if isempty(o.propertiesPanel); return; end

            children = o.propertiesPanel.Parent.Children;
            for i = 1:length(children)
                child = children(i);
                if isa(child,'matlab.ui.container.Panel') && ~isempty(child.UserData)
                    delete(child);
                end
            end
        end

        function panel = findSubPanel(o,subpanelName,removeOthers)
            panel = [];
            children = o.propertiesPanel.Parent.Children;
            for i = 1:length(children)
                child = children(i);
                if isa(child,'matlab.ui.container.Panel') && ~isempty(child.UserData)
                    if strcmp(child.UserData{2},subpanelName); panel = child;
                    elseif removeOthers; delete(child); end
                end
            end
        end

        function switchLabelPanel(o)
            labelPanel = o.findSubPanel('label',true);

            if isempty(labelPanel); PropertiesPanel.createLabelPanel(o);
            else; delete(labelPanel); end
        end

        function switchMarkerPanel(o,size,limits)
            markerPanel = o.findSubPanel('marker',true);

            if isempty(markerPanel); PropertiesPanel.createMarkerPanel(o,size,limits);
            else; delete(markerPanel); end
        end

        function switchFaceAlphaPanel(o)
            faPanel = o.findSubPanel('facealpha',true);

            if isempty(faPanel); PropertiesPanel.createFaceAlphaPanel(o);
            else; delete(faPanel); end
        end
    end
    methods (Access = private,Static)
        function createLabelPanel(o)
            labelPanel = uipanel(o.propertiesPanel.Parent);
            labelPanel.Position = [o.propertiesPanel.Position(1:2) + [40 -75], 90, 70];
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
            editField.ValueChangedFcn = @(src,evt) PropertiesPanel.setLabel(o,evt);

            showLabel = uilabel(grid);
            showLabel.Layout.Row = 2;
            showLabel.Layout.Column = 1;
            showLabel.Text = "Show";

            showCheckbox = uicheckbox(grid);
            showCheckbox.Layout.Row = 2;
            showCheckbox.Layout.Column = 2;
            showCheckbox.Text = "";
            showCheckbox.Value = strcmp(o.geometry.fig.LabelVisible,'on');
            showCheckbox.ValueChangedFcn = @(src,evt) PropertiesPanel.setLabelVisibility(o,evt);
        end

        function createMarkerPanel(o,size,limits)
            markerPanel = uipanel(o.propertiesPanel.Parent);
            markerPanel.Position = [o.propertiesPanel.Position(1:2) + [75 -40], 105, 35];
            markerPanel.UserData = {'subpanel','marker'};

            grid = PropertiesPanel.createContainerGrid(markerPanel,{{25}, {70, 25}},[5 5 5 5]);
            
            markerSize = uislider(grid);
            markerSize.Layout.Row = 1;
            markerSize.Layout.Column = 1;
            markerSize.Limits = limits;
            markerSize.MajorTicks = [];
            markerSize.MinorTicks = [];
            markerSize.Value = size;
            markerSize.ValueChangingFcn = @(src,evt) PropertiesPanel.setMarkerSize(o,evt);

            markerSizeLabel = uilabel(grid);
            markerSizeLabel.Layout.Row = 1;
            markerSizeLabel.Layout.Column = 2;
            markerSizeLabel.Text = string(size);
        end

        function grid = createContainerGrid(panel,size,padding)
            grid = uigridlayout(panel);
            grid.RowHeight = size{1};
            grid.ColumnWidth = size{2};
            grid.Padding = padding;
        end

        function struct = renameField(struct,oldLabel,newLabel)
            struct.(newLabel) = struct.(oldLabel);
            struct = rmfield(struct, oldLabel);
        end

        function changeGeomatplotLabel(Geomatplot,oldLabel,newLabel)
            if isfield(Geomatplot.movs,oldLabel)
                Geomatplot.movs = PropertiesPanel.renameField(Geomatplot.movs,oldLabel,newLabel);
            elseif isfield(Geomatplot.deps,oldLabel)
                Geomatplot.deps = PropertiesPanel.renameField(Geomatplot.deps,oldLabel,newLabel);
            end
        end

        function setFaceColor(o,evt)
            o.geometry.fig.FaceColor = evt.Value;
        end

        function setColor(o,evt)
            o.geometry.fig.Color = evt.Value;
        end

        function setLinestyle(o,evt)
            o.geometry.fig.LineStyle = evt.Value;
        end

        function setLabel(o,evt)
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
    end
end