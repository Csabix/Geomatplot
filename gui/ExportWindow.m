function result = ExportWindow(mainFigure)
    dialogSize = [250 155];
    dialogFig = uifigure('Name','Export Window', ...
                         'WindowStyle','modal','Position',...
                         [mainFigure.Position(1) + (mainFigure.Position(3)-dialogSize(1))/2, ...
                          mainFigure.Position(2) + (mainFigure.Position(4)-dialogSize(2))/2, ...
                          dialogSize]);

    result = {};

    grid = uigridlayout(dialogFig);
    grid.RowHeight = {'fit', 'fit', 'fit', 'fit','fit'};
    grid.ColumnWidth = {'1x', '1x'};
    grid.Padding = [5 5 5 5];

    precLabel = uilabel(grid);
    precLabel.Text = "Numerical Precision:";
    precLabel.Tooltip = "Decimal places for numbers.";
    precisionField = uieditfield(grid, 'numeric');
    precisionField.Limits = [1 10];
    precisionField.Value = 2;

    clfLabel = uilabel(grid);
    clfLabel.Text = "Include CLF:";
    clfLabel.Tooltip = "Include a clf; at the beginning.";
    clfCheckbox = uicheckbox(grid);
    clfCheckbox.Value = 1;
    clfCheckbox.Text = "";

    fPathLabel = uilabel(grid);
    fPathLabel.Text = "Include FilePath:";
    fPathLabel.Tooltip = "Include the filepath at the beginning.";
    fPathCheckbox = uicheckbox(grid);
    fPathCheckbox.Value = 1;
    fPathCheckbox.Text = "";

    limLabel = uilabel(grid);
    limLabel.Text = "Save Lims:";
    limLabel.Tooltip = "Save the current axis limits.";
    limCheckbox = uicheckbox(grid);
    limCheckbox.Value = 1;
    limCheckbox.Text = "";

    confirm = uibutton(grid);
    confirm.Text = "Confirm";
    confirm.ButtonPushedFcn = @(~,~) uiresume(dialogFig);

    cancel = uibutton(grid);
    cancel.Text = "Cancel";
    cancel.ButtonPushedFcn = @(~,~) delete(dialogFig);

    uiwait(dialogFig);

    if isvalid(dialogFig)
        precision = precisionField.Value;
        inclCLF = clfCheckbox.Value;
        inclFP = fPathCheckbox.Value;
        lim = limCheckbox.Value;

        result = {precision, inclCLF, inclFP, lim};
        delete(dialogFig);
    end
end

