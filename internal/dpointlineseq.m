classdef dpointlineseq < dependent
methods
    function v = value(o)
        v = [o.fig.XData(:) o.fig.YData(:)];
    end
    function updatePlot(o,xdata,ydata)
        o.fig.XData = xdata;
        o.fig.YData = ydata;
    end
end
methods (Static)
    function outs = parseOutputs(args)
        if isscalar(args)
            xy = args{1};
            if size(xy,2) == 2
                outs{1} = xy(:,1);  outs{2} = xy(:,2);
            elseif ~isreal(xy) && size(xy,2)==1
                outs{1} = real(xy); outs{2} = imag(xy);
            elseif size(xy,1) == 2
                warning 'Callback output might be of the wrong shape.'
                outs{1} = xy(1,:);  outs{2} = xy(2,:);
            elseif isempty(xy)
                %warning 'Callback with empty output.'
                outs{1} = [];       outs{2} = [];
            else
                error 'Callback output is of the wrong shape.'
            end
        elseif length(args) == 2
            outs{1} = args{1};      outs{2} = args{2};
        else
            error 'Callback has too many outputs.'
        end
    end
end
end