classdef dpolygon < dpointlineseq
methods
    function o = dpolygon(parent,label,inputs,callback,args)
        args = namedargs2cell(args);
        fig = drawPolygon(args{:},"Reshapable",false,"Position",[0,0;0,1;1,1],"Movable",false);
        hidden = false;
        o = o@dpointlineseq(parent,label,fig,inputs,callback,hidden);
    end
end

% TODO .value not consistent with mpolygon

methods (Static,Hidden)
    
end
end