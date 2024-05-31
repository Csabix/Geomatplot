function image = drawImage(location,varargin)
    arguments
        location string
    end
    arguments(Repeating=true)
        varargin
    end
    if mod(numel(varargin),2) == 0
        plt = cplt;
    else
        plt = varargin{1};
        varargin = varargin(2:end);
    end
    defaultPosition = [0,0];
    defaultWidth = 5;

    p = inputParser;
    addParameter(p,"Position",defaultPosition,@(p)isequal(size(p),[1,2]));
    addParameter(p,"Width",defaultWidth,@isscalar);

    parse(p,varargin{:});

    image = ImageH(plt,location,p.Results.Position(1),p.Results.Position(2),p.Results.Width);
end

