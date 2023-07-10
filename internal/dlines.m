classdef dlines < dpointlineseq
methods
    function o = dlines(parent,label,labels,callback,args,varargin)
        o = o@dpointlineseq(parent,label,labels,callback);
        ret = o.call(varargin{:});
        o.fig = line(o.parent.ax,ret{1},ret{2},args{:});
        o.fig.UserData = o;
    end
end
end