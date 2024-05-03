classdef dpointlineseq < dependent
methods
    function v = value(o)
        %v = [o.fig.XData(:) o.fig.YData(:)];
        v = o.fig.Position;
    end
    function updatePlot(o,xdata,ydata)
        %o.fig.XData = xdata;
        %o.fig.YData = ydata;
        if isrow(xdata)
            xdata = xdata';
        end

        if isrow(ydata)
            ydata = ydata';
        end

        o.fig.Position = [xdata,ydata];
    end
end
methods (Static)
    function outs = parseOutputs(args)
        if length(args) == 1
            xy = args{1};
            if size(xy,2) == 2
                outs{1} = xy(:,1);  outs{2} = xy(:,2);
            elseif size(xy,1) == 2
                outs{1} = xy(1,:);  outs{2} = xy(2,:);
            elseif isempty(xy)
                outs{1} = 0;        outs{2} = 0;
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