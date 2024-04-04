classdef Panels
    %PANELS Create panels for the app

    methods (Access = public,Static)
        function propPanel = createPropertiesPanel(figure,position,geometry)
            if isa(geometry,'point_base')
                propPanel = Panels.createPointPanel(figure,position,geometry);
            elseif isa(geometry,'dlines')
                propPanel = Panels.createLinePanel(figure,position,geometry);
            else
                propPanel = [];
            end
        end
    end

    methods(Access = private,Static)
        function createColorDropdown(grid,geometry,gridPos)
            colors = {[1 0 0], [0 1 0], [0 0 1], [0 0 0]};
            colorDropdown = uidropdown(grid);
            colorDropdown.ValueChangedFcn = @(src,evt) Panels.setColor(src,evt,geometry);
            colorDropdown.Layout.Row = gridPos(1);
            colorDropdown.Layout.Column = gridPos(2);
            colorDropdown.Items = repmat({''}, numel(colors), 1);
            colorDropdown.ItemsData = colors;
            for i = 1:numel(colors)
                style = uistyle('BackgroundColor',colors{i});
                addStyle(colorDropdown,style,"item",i);
            end
            %Setting it directly could be a problem if the color is not in
            %the list
            colorDropdown.Value = geometry.fig.Color;
        end

        function grid = createContainerGrid(panel,size,squareSize,padding)
            grid = uigridlayout(panel);
            grid.ColumnWidth = repmat({squareSize},1,size(1));
            grid.RowHeight = repmat({squareSize},1,size(2));
            grid.Padding = padding;
        end

        function propPanel = createPointPanel(figure,position,geometry)
            propPanel = uipanel(figure);
            propPanel.Position = [position + [10 -50], 35, 35];

            grid = Panels.createContainerGrid(propPanel,[1 1],25,[5 5 5 5]);
            Panels.createColorDropdown(grid,geometry,[1 1]);
        end

        function propPanel = createLinePanel(figure,position,geometry)
            propPanel = uipanel(figure);
            propPanel.Position = [position + [10 -50], 70, 35];

            grid = Panels.createContainerGrid(propPanel,[2 1],25,[5 5 5 5]);
            Panels.createColorDropdown(grid,geometry,[1 1]);  

            styles = {'-','--',':','-.'};
            icons = {'gui/resources/LinestyleSolid.png'
                     'gui/resources/LinestyleDashed.png'
                     'gui/resources/LinestyleDotted.png'
                     'gui/resources/LinestyleDashdotted.png'
                    };
            styleDropdown = uidropdown(grid);
            styleDropdown.ValueChangedFcn = @(src,evt) Panels.setLinestyle(src,evt,geometry);
            styleDropdown.Layout.Row = 1;
            styleDropdown.Layout.Column = 2;
            styleDropdown.Items = repmat({''}, numel(styles), 1);
            styleDropdown.ItemsData = styles;
            for i = 1:numel(styles)
                style = uistyle('Icon',icons{i});
                addStyle(styleDropdown,style,"item",i);
            end
            styleDropdown.Value = geometry.fig.LineStyle;
        end

        function setColor(src,evt,geometry)
            geometry.fig.Color = evt.Value;
        end

        function setLinestyle(src,evt,geometry)
            geometry.fig.LineStyle = evt.Value;
        end
    end
end