function label = drawLabel(text,varargin)
    if mod(numel(varargin),2) == 0
        plt = cplt;
    else
        plt = varargin{1};
        varargin = varargin(2:end);
    end
    p = inputParser;
    p.KeepUnmatched = true;

    addParameter(p,"Position",[0,0]);
    addParameter(p,"Offset",[0,0]);
    addParameter(p,"Visible",true);

    parse(p,varargin{:});

    label = LabelH(plt, convertCharsToStrings(text), p.Results.Position, p.Results.Offset, p.Results.Visible);
end

