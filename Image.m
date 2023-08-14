function h = Image(varargin)
% Image  visualizes a given 2D function over an area
%   Image({A,B,...},callback) draws an image using the given callback function handle of the form
%           callback(X,Y,A,B,...) -> C
%       where A,B,... are n >= 1 number of any Geomaplot handles, and their values will be passed to
%       the given callback. For example, if A is a point, then its position vector [x y] will be
%       given to the callback to calculate with. The parameter X and Y are given automatically and
%       are NxM matrices retuned from a meshgrid command. The X(i,j) and Y(i,j) position corresponds
%       to the position it appears on the canvas. The output is expected to be an NxM array of
%       function evaluations or NxMx3 array for colors.
%       Note that if the callback throws any error, the excecution does not stop, the image goes
%       into the 'undefined' state and it will not be drawn.
%       For example, the following visualizes the distance function of a single point:
%           Image({Point},)
%
%   Image({A,B,...},callback,corner0,corner1)  specifies a corners (eg. lower left and upper right)
%       of the plotted region. The values may be two element position vectors, or even point objects
%       allowing for dynamically changing the visualized function domain. The default corners are
%       [0,0] and [1,1]. 
%
%   Image(label,{___})  provides a label for the curve. The label is not drawn.
%
%   Image(parent,___)  draws onto the given geomatplot, axes, or figure instead of
%       the current one. Thus must preceed the label argument if that is given also.
%
%   Image(___,Name,Value)  specifies additional properties using one or more Name,
%       Value pairs arguments.
%
%   h = Image(___)  returns the created handle.
%
%   See also Curve, POINT, DISTANCE, Circle

    [parent,varargin] = Geomatplot.extractGeomatplot(varargin);  
    [label,varargin]  = parent.extractLabel(varargin,'image');
    [inputs,varargin] = parent.extractInputs(varargin);
    [usercallback,corner0,corner1,params,options]= parse_(inputs,varargin{:});
    nins = length(inputs);
    nain = nargin(usercallback);
    nout = nargout(usercallback);

    function varargout = img_cpu_real_matrix(xr,xn,yr,yn,varargin)
        x = linspace(xr(1),xr(2),xn) ;
        y = linspace(yr(1),yr(2),yn)';
        [x,y] = meshgrid(x,y);
        args  = cell(1,nins);
        for i = 1:nins; args{i} = varargin{i}.value; end
        [varargout{1:nout}] = usercallback(x,y,args{:});
    end   
    function varargout = img_cpu_real_arrayfun(xr,xn,yr,yn,varargin)
        x = linspace(xr(1),xr(2),xn) ;
        y = linspace(yr(1),yr(2),yn)';
        %[x,y] = meshgrid(x,y);
        args  = cell(1,nins);
        for i = 1:nins; args{i} = varargin{i}.value; end
        function varargout = capture_args(x,y)
            [varargout{1:nout}] = usercallback(x,y,args{:});
        end
        [varargout{1:nout}] = arrayfun(@capture_args,x,y);
    end
    function varargout = img_cpu_cplx_matrix(xr,xn,yr,yn,varargin)
        x = linspace(xr(1),xr(2),xn) ;
        y = linspace(yr(1),yr(2),yn)';
        [x,y] = meshgrid(x,y);
        args  = cell(1,nins);
        for i = 1:nins
            v = varargin{i}.value;
            args{i} = complex(v(:,1),v(:,2));
        end
        [varargout{1:nout}] = usercallback(complex(x,y),args{:});
    end
    function varargout = img_cpu_cplx_arrayfun(xr,xn,yr,yn,varargin)
        x = linspace(xr(1),xr(2),xn) ;
        y = linspace(yr(1),yr(2),yn)';
        [x,y] = meshgrid(x,y);
        args  = cell(1,nins);
        for i = 1:nins
            v = varargin{i}.value;
            args{i} = complex(v(1),v(2));
        end
        function varargout = capture_args(z)
            [varargout{1:nout}] = usercallback(z,args{:});
        end
        [varargout{1:nout}] = arrayfun(@capture_args,complex(x,y));
    end
    function out = img_gpu_cplx_arrayfun_1(xr,xn,yr,yn,varargin)
        x = gpuArray.linspace(xr(1),xr(2),xn) ;
        y = gpuArray.linspace(yr(1),yr(2),yn)';
        [x,y] = meshgrid(x,y);
        args  = cell(1,nins);
        for i = 1:nins
            v = varargin{i}.value;
            args{i} = complex(v(1),v(2));
        end
        out = gather(arrayfun(usercallback,complex(x,y),args{:}));
    end
    function [r,g,b] = img_gpu_cplx_arrayfun_3(xr,xn,yr,yn,varargin)
        x = gpuArray.linspace(xr(1),xr(2),xn) ;
        y = gpuArray.linspace(yr(1),yr(2),yn)';
        [x,y] = meshgrid(x,y);
        args  = cell(1,nins);
        for i = 1:nins
            v = varargin{i}.value;
            args{i} = complex(v(1),v(2));
        end
        [r,g,b] = arrayfun(usercallback,complex(x,y),args{:});
        [r,g,b] = gather(r,g,b);
    end
    function varargout = img_gpu_real_matrix(xr,xn,yr,yn,varargin)
        x = gpuArray.linspace(xr(1),xr(2),xn) ;
        y = gpuArray.linspace(yr(1),yr(2),yn)';
        [x,y] = meshgrid(x,y);
        args  = cell(1,nain);
        for i = 1:nain; args{i} = varargin{i}.value; end
        [varargout{1:nout}] = usercallback(x,y,args{:});
    end   


    if options.gpuArray
        if options.Complex
            if options.ArrayFun
                switch nout
                case 1; callback = @img_gpu_cplx_arrayfun_1;
                case 3; callback = @img_gpu_cplx_arrayfun_3;
                end
            else % matrix
                error 'Not supported'
            end
        else % real
            if options.ArrayFun
                error 'Not supported'
            else % matrix
                callback = @img_gpu_real_matrix;
            end
        end
    else % cpu
        if options.Complex
            if options.ArrayFun
                callback = @img_cpu_cplx_arrayfun;
            else % matrix
                callback = @img_cpu_cplx_matrix;
            end
        else % real
            if options.ArrayFun
                callback = @img_cpu_real_arrayfun;
            else % matrix
                callback = @img_cpu_real_matrix;
            end
        end
    end
    
    h_ = dimage(parent,label,inputs,callback,corner0,corner1,params,options.Resolution);

    if nargout == 1; h=h_; end
end

function [usercallback,corner0,corner1,params,options] = parse_(inputs,usercallback,corner0,corner1,params,options)
    arguments
        inputs                  (1,:) cell                                          %#ok<INUSA> 
        usercallback            (1,1) function_handle {mustBeImageCallback(usercallback,inputs)}
        corner0                                       {mustBePoint} = [0 0]
        corner1                                       {mustBePoint} = [1 1]
        params.Interpolation    (1,:) char   {mustBeMember(params.Interpolation,{'nearest','bilinear'})} = 'bilinear';
        params.CDataMapping     (1,:) char   {mustBeMember(params.CDataMapping,{'direct','scaled'})}
        params.AlphaDataMapping (1,:) char   {mustBeMember(params.AlphaDataMapping,{'none','scaled','direct'})}
        params.AlphaData        (:,:) double
        params.MaxRenderedResolution
        options.Resolution      (1,1) double  {mustBeInteger,mustBePositive}  = 256
        options.gpuArray        (1,1) logical = false;
        options.ArrayFun        (1,1) logical = false;
    end
    options.Complex = length(inputs)+1 == nargin(usercallback);
end

function mustBeImageCallback(usercallback,inputs)
    nins = length(inputs);
    nain = nargin(usercallback);
    nout = nargout(usercallback);
    if ~any(nain == nins+[1,2])
        msgType = ['Callback needs ' int2str(nins+1) ' or ' int2str(nins+2) ' input arguments with the first one either beeing a complex number, or the first two being the X and Y sample positions.'];
        throw(MException('Image:callbackWrongNumberOfArguments',msgType));
    end
    if ~any(nout == [1,3])
        msgType = 'Callback needs 1 or 3 output arguments for grayscale or color output.';
        throw(MException('Image:callbackWrongNumberOfArguments',msgType));
    end
end

function mustBePoint(x)
    if ~(isnumeric(x) && length(x)==2 || isa(x,'point_base'))
        throwAsCaller(MException('mustBePoint:notPoint','The input must be a position or a point drawing'));
    end
end
