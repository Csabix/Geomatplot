classdef betterInputParser < handle
properties (Access=public)
    FunctionName = '';
    CaseSensitive (1,1) logical = false;
    KeepUnmatched (1,1) logical = false;
    PartialMatching (1,1) logical = true;
    StructExpand (1,1) logical = true;
end
properties (SetAccess=protected, GetAccess=public)
    Parameters (1,:) cell = {};
    Results (1,1) struct
    Unmatched (1,1) struct
    UsingDefaults cell
end
properties (Access=private)
    data (1,:) struct
end
methods
    function o = betterInputParser(); end

    function parse(o,varargin)
        p = inputParser;
        p.FunctionName = o.FunctionName;
        p.CaseSensitive = o.CaseSensitive;
        p.KeepUnmatched = o.KeepUnmatched;
        p.PartialMatching = o.PartialMatching;
        p.StructExpand = o.StructExpand;

        fnames = []; fvals = [];
        vind = 1; dind = 1; args = {};
        while vind <= length(varargin) && dind <= length(o.data)
            arg = varargin{vind};
            d = o.data(dind);
            switch o.data(dind).type
            case 'r'
                p.addRequired(d.argName,d.validationFcn);
                args = [args {arg}]; %#ok<*AGROW> 
            case 'o'
                if d.validationFcn(arg)
                    p.addOptional(d.argName,d.defaultVal,d.validationFcn);
                    args = [args {arg}];
                else
                    fnames = [fnames {d.argName}];
                    fvals  = [fvals {d.defaultVal}];
                    vind = vind - 1; % skipped optional
                end
            case 'p'
                p.addParameter(d.argName,d.defaultVal,d.validationFcn);
                args = [args {arg}];
            end
            vind = vind + 1;
            dind = dind + 1;
        end
        % remaining optionals:
        for i = dind:length(o.data)
            d = o.data(i);
            fnames = [fnames {d.argName}];
            fvals  = [fvals {d.defaultVal}];
        end

        p.parse(args{:})
        o.Results = p.Results;
        o.Unmatched = p.Unmatched;
        o.UsingDefaults = p.UsingDefaults;
        for dind=1:length(fnames)
            o.Results.(fnames{dind}) = fvals{dind};
        end
    end

    function addRequired(o,argName,validationFcn)
        if nargin < 3;validationFcn = @(~) true; end
        o.data(end+1).type = 'r';
        o.data(end).argName = argName;
        o.data(end).validationFcn = validationFcn;
        o.Parameters = [o.Parameters {argName}];
    end
    function addOptional(o,argName,defaultVal, validationFcn)
        if nargin < 4;validationFcn = @(~) true; end
        o.data(end+1).type = 'o';
        o.data(end).argName = argName;
        o.data(end).defaultVal = defaultVal;
        o.data(end).validationFcn = validationFcn;
        o.Parameters = [o.Parameters {argName}];
    end
    function addParameter(o,argName,defaultVal, validationFcn)
        if nargin < 4;validationFcn = @(~) true; end
        o.data(end+1).type = 'p';
        o.data(end).argName = argName;
        o.data(end).defaultVal = defaultVal;
        o.data(end).validationFcn = validationFcn;
        o.Parameters = [o.Parameters {argName}];
    end
end
end