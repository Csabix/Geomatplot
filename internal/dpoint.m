classdef dpoint < dependent & point_base
methods
    function o = dpoint(parent,label,inputs,callback,args)
        if nargin < 5
            args.Color='k'; args.MarkerSize=6; args.LabelAlpha=0; args.LabelTextColor='k';
            args.Label=label; args.LabelVisible ='hover';
        end
        args = namedargs2cell(args);
        fig = drawpoint('InteractionsAllowed','none',args{:},'Position',[0 0]);
        o = o@dependent(parent,label,fig,inputs,callback);
    end
    function v = value(o)
        v = o.fig.Position;
    end
    function updatePlot(o,pos)
        o.fig.Position = pos;
    end
end
methods (Static)
    function outs = parseOutputs(args)
        if length(args)==1
            outs{1} = args{1}(:)';
        elseif length(args)==2
            outs{1} = [args{1}(:) args{2}(:)];
        else
            error 'Callback has too many outputs.'
        end
    end
end
end