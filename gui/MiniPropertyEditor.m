classdef MiniPropertyEditor < handle

    properties
        Figure
        ColorSlider
        SizeSlider
        NameEdit
        ApplyButton
    end

    methods
        function obj = MiniPropertyEditor(app,cursorPosition)
            % Create a figure
            obj.Figure = uifigure('Name', 'Mini Property Editor', 'Position', [cursorPosition(1), cursorPosition(2), 200, 150]);

            % Add sliders, text fields, and buttons to the figure
            % Customize based on your requirements
            obj.ColorSlider = uicontrol(obj.Figure, 'Style', 'slider', 'Position', [10, 100, 120, 20]);
            obj.SizeSlider = uicontrol(obj.Figure, 'Style', 'slider', 'Position', [10, 70, 120, 20]);
            obj.NameEdit = uicontrol(obj.Figure, 'Style', 'edit', 'Position', [10, 40, 120, 20]);
            obj.ApplyButton = uicontrol(obj.Figure, 'Style', 'pushbutton', 'Position', [10, 10, 80, 30], 'String', 'Apply', 'Callback', @(src, event) obj.ApplyButtonCallback(app));

            % Set initial values based on the current button properties
            %set(obj.ColorSlider, 'Value', app.ButtonColor(1));
            %set(obj.SizeSlider, 'Value', app.ButtonSize(1));
            %set(obj.NameEdit, 'String', app.ButtonName);
        end

        function ApplyButtonCallback(obj, app)
            % Update the button properties based on user input
            %app.ButtonColor = [get(obj.ColorSlider, 'Value'), 0, 0];  % Adjust as needed
            %app.ButtonSize = [get(obj.SizeSlider, 'Value'), 30];  % Adjust as needed
            %app.ButtonName = get(obj.NameEdit, 'String');
            % Update the button in the main app
            % You can set the button properties here
            % For example:
            % app.Button.BackgroundColor = app.ButtonColor;
            % app.Button.Position = [app.Button.Position(1), app.Button.Position(2), app.ButtonSize];
            % app.Button.Text = app.ButtonName;

            % Close the mini property editor
            delete(obj.Figure);
        end
    end
end