function h = Image(varargin)% Image  visualizes a given 2D function over an area%   Image(A,B,...,callback) draws an image using the given callback function handle of the form%           callback(X,Y,A,B,...) -> C      (real input) or%           callback(Z,A,B,...) -> C        (complex input)%       where A,B,... are n >= 1 number of any Geomaplot handles, and their values will be passed to%       the given callback. For example, if A is a point, then its position vector A=[x y] or%       A=x+1i*y will be given to the callback to calculate with. The parameters X, Y or Z are given%       automatically and are NxM matrices retuned from a meshgrid command Z = X + 1i*A. The X(i,j) %       and Y(i,j) position corresponds to the position it appears on the canvas. The output is%       expected to be an NxM array of function evaluations or NxMx3 array for colors. Note that if%       the callback throws any error, the excecution does not stop, the image goes into the%       'undefined' state and it will not be drawn. E.g.: visualize distance from a single A point:%           Image({Point},@(z,A) abs(z-A))%%   Image(A,B,...,callback,corner0,corner1)  specifies a corners (eg. lower left and upper right)%       of the plotted region. The values may be two element position vectors, or even point objects%       allowing for dynamically changing the visualized function domain. The default corners are%       [0,0] and [1,1]. %%   Image(label,{___})  provides a label for the curve. The label is not drawn.%%   Image(parent,___)  draws onto the given geomatplot, axes, or figure instead of%       the current one. Thus must preceed the label argument if that is given also.%%   Image(___,Name,Value)  specifies additional properties using one or more Name,%       Value pairs arguments.%%   h = Image(___)  returns the created handle.%   %   Name-Value Arguments%%       Resolution - 1024 (default) | positive integer%           The Image will have approximately Resolution^2 number of pixels. Width and height are%           determined automatically for square pixels. When someting is being moved the resolution%           is decreased to increase responsiveness.%%       CallbackType - 'matrix' (default) | 'vectorize'%           If callback type is 'matrix', a mesgrid is created and given as an input to the callback%           function supporting matrix operations (typically '.*','./','.^'). The 'vectorize' option%           generates a different call for every x,y coorinate. Unless running on the GPU, this can%           be very slow even with our implemented CPU thread parallelization.%%       Device - 'CPU' (default) | 'GPU'%           Running operations on the GPU can significantly speed up Image update operations,%           especially for a high Resolution. When the CallbackType = 'matrix', the inputs are%           converted to gpuArray-s, so the callback should support these. When the CallbackType = %           'vectorize', Image (gpuArray.arrayfun) tries to compile the whole callback function into%           a single gpu kernel. Generally, this GPU-vectorized solution is the fastest, but comes%           with many limitations explained in gpuArray.arrayfun. Additionally, inputs can only be%           points, scalars and vectors, and Representation must be 'complex'.%%       Representation - 'real' | 'complex'%           By default, this property is deduced from the callback and governs how the input is%           supplied to the callback function. If the callback has two more input arguments than%           input drawings given to Image, Representation will be 'real'. If it has one more%           arguments then the number of input drawings, Representation will be 'complex'. A%           'complex' callback has the following form:%               callback(z,A,B,...)->real%           where z is the position encoded as a complex number z=x+i*y; and all other inputs are%           converted to complex numbers. Performance impact of Representation is mostly minimal.%%       Precision - 'double' (default) | 'single' | 'half'%           Determines the artihmetic precision. 'single' is often faster, 'half' does not have many%           supported functions and it is often slower.%%       Verbose - true (default)| false%           If true, Image prints basic information during construction.%%   Name-Value Arguments from matlab image command%       Interpolation, CDataMapping, AlphaDataMapping, AlphaData, MaxRenderedResolution%       For more information read the matlab image plotting documentation.%       Note that 'bilinear' Interpolation is default for Image here.%%   See also image, gpuArray, gpuArray.arrayfun, Curve, Point    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);      [label,varargin]  = parent.extractLabel(varargin,'image');    [inputs,varargin] = parent.extractInputs(varargin);    [usercallback,corner0,corner1,params,options]= parse_(inputs,varargin{:});    nout = abs(nargout(usercallback));    %% helper functions    function args = values_of(args)        if options.Complex            for i=1:length(args)                v = args{i}.value;                vv = cast(v,options.Precision);                if isa(v,'dscalar')                    args{i} = vv;                else                    args{i} = complex(vv(:,1),vv(:,2));                end            end        else            for i=1:length(args)                args{i} = cast(args{i}.value,options.Precision);            end        end    end        function [x,y] = linspace_meshgrid(xr,xn,yr,yn)        if options.gpuArray            x = gpuArray.linspace(cast(xr(1),options.Precision),xr(2),xn);            y = gpuArray.linspace(cast(yr(1),options.Precision),yr(2),yn);        else            x = linspace(cast(xr(1),options.Precision),xr(2),xn);            y = linspace(cast(yr(1),options.Precision),yr(2),yn);        end        [x,y] = meshgrid(x,y);        if nargout == 1; x = complex(x,y); end    end    %% callback zoo    function varargout = img_cpu_real_matrix(xr,xn,yr,yn,varargin)        [x,y] = linspace_meshgrid(xr,xn,yr,yn);        args = values_of(varargin);        if xn*yn > 1000*1000 && ~strcmp(options.Precision,'half')            if isempty(gcp('nocreate')); parpool('Threads');end            switch nout            case 1                spmd                    lo = round((spmdIndex-1)*xn/spmdSize)+1;                     hi = round((spmdIndex+0)*xn/spmdSize)+0;                    r = usercallback(x(lo:hi,:),y(lo:hi,:),args{:});                end                varargout = {vertcat(r{:})};            case 3                spmd                    lo = round((spmdIndex-1)*xn/spmdSize)+1;                     hi = round((spmdIndex+0)*xn/spmdSize)+0;                    [r,g,b] = usercallback(x(lo:hi,:),y(lo:hi,:),args{:});                end                varargout = {vertcat(r{:}),vertcat(g{:}),vertcat(b{:})};            end        else            [varargout{1:nout}] = usercallback(x,y,args{:});        end    end       function varargout = img_cpu_cplx_matrix(xr,xn,yr,yn,varargin)        z = linspace_meshgrid(xr,xn,yr,yn);        args = values_of(varargin);        if xn*yn > 1000*1000 && ~strcmp(options.Precision,'half')            if isempty(gcp('nocreate')); parpool('Threads');end            switch nout            case 1                spmd                    lo = round((spmdIndex-1)*xn/spmdSize)+1;                     hi = round((spmdIndex+0)*xn/spmdSize)+0;                    r = usercallback(z(lo:hi,:),args{:});                end                varargout = {vertcat(r{:})};            case 3                spmd                    lo = round((spmdIndex-1)*xn/spmdSize)+1;                     hi = round((spmdIndex+0)*xn/spmdSize)+0;                    [r,g,b] = usercallback(z(lo:hi,:),args{:});                end                varargout = {vertcat(r{:}),vertcat(g{:}),vertcat(b{:})};            end        else            [varargout{1:nout}] = usercallback(z,args{:});        end    end    function varargout = img_cpu_real_arrayfun(xr,xn,yr,yn,varargin)        args = values_of(varargin);        xa = xr(1); ya = yr(1);        xd = diff(xr); yd = diff(yr);        if xn*yn > 100*100 && ~strcmp(options.Precision,'half')            r = zeros(yn,xn);            if isempty(gcp('nocreate')); parpool('Threads'); end            switch nout            case 1                parfor i=1:xn                    x = xa+(i-1)/(xn-1)*xd;                    ri = zeros(1,yn);                    for j = 1:yn                        y = ya+(j-1)/(yn-1)*yd;                        ri(j) = usercallback(x,y,args{:}); %#ok<PFBNS>                     end                    r(:,i) = ri;                end                varargout = {r};            case 3                g = r; b = r;                parfor i=1:xn                    x = xa+(i-1)/(xn-1)*xd;                    ri = zeros(1,yn); gi = ri; bi = ri;                    for j = 1:yn                        y = ya+(j-1)/(yn-1)*yd;                        [ri(j),gi(j),bi(j)] = usercallback(x,y,args{:}); %#ok<PFBNS>                     end                    r(:,i) = ri; g(:,i) = gi; b(:,i) = bi;                end                varargout = {r,g,b};            end        else            for i = 1:xn                x = xa+(i-1)/(xn-1)*xd;                for j = 1:yn                    y = ya+(j-1)/(yn-1)*yd;                    [varargout{1:nout}(i,j)] = usercallback(x,y,args{:});                end            end        end    end    function varargout = img_cpu_cplx_arrayfun(xr,xn,yr,yn,varargin)        args = values_of(varargin);        xa = xr(1); ya = yr(1);        xd = diff(xr); yd = diff(yr);        if xn*yn > 100*100 && ~strcmp(options.Precision,'half')            r = zeros(yn,xn);            if isempty(gcp('nocreate')); parpool('Threads');end            switch nout            case 1                parfor i=1:xn                    x = xa+(i-1)/(xn-1)*xd;                    ri = zeros(1,yn);                    for j = 1:yn                        y = ya+(j-1)/(yn-1)*yd;                        ri(j) = usercallback(complex(x,y),args{:}); %#ok<PFBNS>                     end                    r(:,i) = ri;                end                varargout = {r};            case 3                g = r; b = r;                parfor i=1:xn                    x = xa+(i-1)/(xn-1)*xd;                    ri = zeros(1,yn); gi = ri; bi = ri;                    for j = 1:yn                        y = ya+(j-1)/(yn-1)*yd;                        [ri(j),gi(j),bi(j)] = usercallback(complex(x,y),args{:}); %#ok<PFBNS>                     end                    r(:,i) = ri; g(:,i) = gi; b(:,i) = bi;                end                varargout = {r,g,b};            end        else            for i = 1:xn                x = xa+(i-1)/(xn-1)*xd;                for j = 1:yn                    y = ya+(j-1)/(yn-1)*yd;                    [varargout{1:nout}(i,j)] = usercallback(complex(x,y),args{:});                end            end        end    end    function varargout = img_gpu_cplx_arrayfun(xr,xn,yr,yn,varargin)        args = values_of(varargin);        z = linspace_meshgrid(xr,xn,yr,yn);        switch nout                    case 1            varargout{1} = arrayfun(usercallback,z,args{:});        case 3            [varargout{1},varargout{2},varargout{3}] = arrayfun(usercallback,z,args{:});        end    end    function varargout = img_gpu_real_matrix(xr,xn,yr,yn,varargin)        args = values_of(varargin);        [x,y] = linspace_meshgrid(xr,xn,yr,yn);        [varargout{1:nout}] = usercallback(x,y,args{:});    end    function varargout = img_gpu_cplx_matrix(xr,xn,yr,yn,varargin)        args = values_of(varargin);        z = linspace_meshgrid(xr,xn,yr,yn);        [varargout{1:nout}] = usercallback(z,args{:});    end    %% rest    if options.gpuArray        if options.Complex            if options.ArrayFun                for k = 1:length(inputs)                    l = inputs{k};                    if ~(isa(l,'point_base') || isa(l,'dnumeric'))                        throw(MException('Image:invalidInput','The input cannot be of this type.'));                    end                end                callback = @img_gpu_cplx_arrayfun;            else % matrix                callback = @img_gpu_cplx_matrix;            end        else % real            if options.ArrayFun                error 'Image cannot run in with gpuArray.arrayfun with real inputs. Use complex callback function.'            else % matrix                callback = @img_gpu_real_matrix;            end        end    else % cpu        if options.Complex            if options.ArrayFun                if options.Resolution > 1024                    error 'Image too large. Consider using the GPU or matrix operations.'                end                callback = @img_cpu_cplx_arrayfun;            else % matrix                callback = @img_cpu_cplx_matrix;            end        else % real            if options.ArrayFun                if options.Resolution > 1024                    error 'Image too large. Consider using the GPU or matrix operations.'                end                callback = @img_cpu_real_arrayfun;            else % matrix                callback = @img_cpu_real_matrix;            end        end    end        h_ = dimage(parent,label,inputs,callback,corner0,corner1,params,options);    if nargout == 1; h=h_; endendfunction [usercallback,corner0,corner1,params,options] = parse_(inputs,usercallback,corner0,corner1,params,options)    arguments        inputs                  (1,:) cell         usercallback            (1,1) function_handle {mustBeImageCallback(usercallback,inputs)}        corner0                                       {mustBePoint} = [0 0]        corner1                                       {mustBePoint} = [1 1]        params.Interpolation    (1,:) char   {mustBeMember(params.Interpolation,{'nearest','bilinear'})} = 'bilinear';        params.CDataMapping     (1,:) char   {mustBeMember(params.CDataMapping,{'direct','scaled'})}        params.AlphaDataMapping (1,:) char   {mustBeMember(params.AlphaDataMapping,{'none','scaled','direct'})}        params.AlphaData        (:,:) double        params.MaxRenderedResolution        options.Resolution      (1,1) double  {mustBeInteger,mustBePositive}  = 1024        options.Device          (1,:) char {mustBeMember(options.Device,{'gpu','GPU','cpu','CPU'})}     = 'cpu'        options.CallbackType    (1,:) char {mustBeMember(options.CallbackType,{'matrix','vectorize','vectorized'})} = 'matrix'        options.Precision       (1,:) char = 'double'        options.Verbose         (1,1) logical = true        options.Representation  (1,:) char {mustBeMember(options.Representation,{'real','complex'})}    end    options.ArrayFun = ~strcmp(options.CallbackType,'matrix');    options.gpuArray = strcmpi(options.Device,'gpu');    options.Complex  = length(inputs)+1 == nargin(usercallback);    if isfield(options,'Representation') && strcmp(options.Representation,'complex')~= options.Complex        error 'The ''Representation'' given does not match the number of arguments of the supplied callback function.'    endendfunction mustBeImageCallback(usercallback,inputs)    nins = length(inputs);    nain = nargin(usercallback);    nout = abs(nargout(usercallback));    if ~any(nain == nins+[1,2])        msgType = ['Callback needs ' int2str(nins+1) ' or ' int2str(nins+2) ' input arguments with the first one either beeing a complex number, or the first two being the X and Y sample positions.'];        throw(MException('Image:callbackWrongNumberOfArguments',msgType));    end    if ~any(nout == [1,3])        msgType = 'Callback needs 1 or 3 output arguments for grayscale or color output.';        throw(MException('Image:callbackWrongNumberOfArguments',msgType));    endendfunction mustBePoint(x)    if ~(isnumeric(x) && length(x)==2 || isa(x,'point_base'))        throwAsCaller(MException('mustBePoint:notPoint','The input must be a position or a point drawing'));    endend