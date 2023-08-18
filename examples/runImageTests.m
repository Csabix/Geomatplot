function result = runImageTests(resolutions)
    arguments
        resolutions (1,:) double {mustBePositive} = 1024;
    end
    Resolution = num2cell(resolutions);
    Precision = {'single','double'};         % Type = {'double'};
    Device = {'CPU','GPU'};                    % Device = {'CPU'};
    CallbackType = {'matrix','vectorize'};     % CallbackType = {'matrix'};
    Representation = {'real','complex'};       % Representation = {'real','complex'};
    names = {'Resolution','Precision','Device','CallbackType','Representation'};

    options = setprod(Resolution,Precision,Device,CallbackType,Representation);
    options = cell2struct(options,names,2);
    result = options;
    
    result(1).AverageTime = 0;
    for i=1:length(options)
        result(i) = run_test(options(i));
    end
    
    result = struct2table(result);

    for i=1:length(names)
        col = result.(names{i});
        if iscellstr(col) || isstring(col)
            result.(names{i}) = categorical(col);
        end
    end
end

function C = setprod(varargin)
    if nargin ==0; C={}; return; end
    C = varargin{1}(:);
    for i = 2:length(varargin)
        [~,m] = size(C);
        [A,B] = meshgrid(C,varargin{i});
        C = [reshape(A,[],m),reshape(B(1:end/m),[],1)];
    end
end

function result = run_test(option)
    clf; result = option;
    result.AverageTime = NaN;
    A = Point([0.1 0.2]); B = Point([0.7 0.9]); C = Point([0.9 0.2]);
    if strcmp(option.CallbackType,'matrix')
        fun = @dist2bezier_matrix;
    else
        fun = @dist2bezier;
    end
    if strcmp(option.Representation,'real')
        fun = @(x,y,A,B,C) fun(complex(x,y),complex(A(1),A(2)),complex(B(1),B(2)),complex(C(1),C(2)));
    end
    args = namedargs2cell(option);
    t1 = tic;
    try
        Image(A,B,C,fun,args{:});
    catch ME
        warning(ME.getReport);
        return;
    end
    
    fig = A.fig;
    evt.EventName = 'ROIMoved';

    if toc(t1) < 1
        moveable.update(fig,evt); % (more) warmup if didnt waste much time so far
    end

    testnum = 10;
    
    t2 = tic;
    for i = 1:testnum
        moveable.update(fig,evt);
        if toc(t2) > 2; break; end % early out after 2s
    end
    result.AverageTime = 1000*toc(t2)/i; % avg in ms
end