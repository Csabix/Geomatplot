%% Triangle
clf; disp Triangle

A = Point([0.0 0.0]);     % draggable point, automatically labelled A
B = Point([1.0 0.0]);     % automatic labels are applied if no label is given
C = Point([0.6 .55]);
ab = Segment(A,B,'b',2);  % a blue segment from A and B
bc = Segment(B,C,'b',2);  %         with LineWidth of 2
cd = Segment(C,A,'b',2);

Segment(A,Midpoint(B,C),'--')
Segment(B,Midpoint(C,A),'--')
Segment(C,Midpoint(A,B),'--')
S=Midpoint('S',A,B,C,'k',7); % Barycenter of the triangle labelled S

PerpendicularBisector(A,B,':')
PerpendicularBisector(B,C,':')
PerpendicularBisector(C,A,':')
[~,K] = Circle(A,B,C,'m--'); % Magenta dashed circumcircle of the triangle

la = AngleBisector(A,B,C,':');
lb = AngleBisector(B,C,A,':');
lc = AngleBisector(C,A,B,':');
Circle(Intersect('O',la,lb),ab,'c'); % (inscribed) circle touching segment AB

ma = PerpendicularLine(A,B,C,':');
mb = PerpendicularLine(B,C,A,':');
mc = PerpendicularLine(C,A,B,':');
M = Intersect('M',ma,mb);
Segment(M,K,'r')

ylim([-0.2 0.6]); xlim([-.1 1.1]);

%% Intersect
clf; disp Intersect
A = Point([0 1]); 
B = Point([1 0]); 
C = Point([0 0]);
f = Polygon([-1 0;1 0;1 1;0.7 0.7;0.3 0.5;0 0.9;-0.5 0.3;-1 0.3],'g');
D = Point([.6 .6]);
a = Circle(A,B);
b = Circle(C,D);
Intersect(2,a,b)
Intersect(5,a,f)

D1 = Mirror(D,f);
D2 = Mirror(D,A);
D11 = Mirror(D1,A);

%% Polygon Sphere trace
clf; disp Polygon

% You can move, create, delete vertices of the following polygon:
f = Polygon([-1 0;1 0;1 1;0.7 0.7;0.3 0.5;0 0.9;-0.5 0.3;-1 0.3],'b');

p0 = Point('p0',[-.8,1.0 ],'r');
q0 = Point('q0',[.5 ,1.05],'r',5);
v0 = Eval((q0-p0)/Distance(p0,q0)); % Operators: point-point=vector, vector/scalar = vector

Ray(p0,q0,'r',1.5);

p = p0; n=10; % Sphere tracing illustration:
for i = 1:n
    d = Distance(p,f); % distance to polygon yields a dependent scalar value
    Circle(p,d,'Color',[i/n 1-i/n 0])
    p = (p + v0*d)';      % vector*scalar=vector, point+vector=point
end

xlim([-1.5 1.3]); ylim([0 1.7]); 

%% Image
clf; disp Image
b0 = Point('b0',[0.1 0.2],'r'); % draggable control points
b1 = Point('b1',[0.7 0.9],'r'); % with given labels
b2 = Point('b2',[0.9 0.2],'r');
%c1 = Point('c1',[-.5 0],'k','MarkerSize',5); % adjustable corner
%c2 = Point('c2',[1.5 1],'k','MarkerSize',5); %   for the image

% parametric callback with t in [0,1] and dependent variables:
bt = @(t,b0,b1,b2)  b0.*(1-t).^2 + 2*b1.*t.*(1-t) + b2.*t.^2;
b = Curve(b0,b1,b2,bt,'r',2); % A red quadratic Bézier curve

iscplx = false;
isgpua = false;
isafun = false;
fun = getDist2bezierFun(iscplx,isafun);

Image(b0,b1,b2,fun,'gpuArray',isgpua,'ArrayFun',isafun);
colorbar;
% where 'dist2bezier' is a (x,y,b0,b1,b2) -> real function

%P = Point('P',[.5 .4],'y');
%Circle(P,b,'y');

%% dist2bezier

function fun = getDist2bezierFun(iscplx,isafun)
    function res = dist2bezier_matrix(pos,A,B,C)
    % adapted from https://iquilezles.org/articles/distfunctions2d/
        function c = gdot(a,b)
            c = real(conj(a).*b);
        end
        function c = gdot2(a)
            c = gdot(a,a);
        end
        function v = clamp(x,a,b)
            v = min(max(x,a),b);
        end
	    a = B - A;
        b = A - 2.0*B + C;                     
        c = a * 2.0;                           
        d = A - pos;                           
        kk = 1.0./gdot(b,b);                   
        kx = kk.*gdot(a,b);                    
        ky = kk.*(2.0*gdot(a,a)+gdot(d,b))/3.0;
        kz = kk.*gdot(d,a);                    
        p = ky - kx.*kx;                       
        p3 = p.*p.*p;                          
        q = kx.*(2*kx.*kx-3*ky) + kz;          
        h = q.*q + 4*p3;                       
        res = 0*ky+1;
        mask = h>=0;
        % if mask
            h = realsqrt(h(mask));
            uv1 = nthroot(.5*( h-q(mask)),3);     
            uv2 = nthroot(.5*(-h-q(mask)),3);     
            t   = clamp( uv1+uv2-kx, 0, 1 );
            res(mask) = gdot2((c + b.*t).*t + d(mask));
        % else
            z  = realsqrt(-p(~mask));               
            v  = acos( q(~mask)./(p(~mask).*z.*2) ) / 3;   
            m  = cos(v);                     
            n  = sin(v)*sqrt(3);             
            t1 = clamp( (m+m).*z-kx,0,1);    
            t2 = clamp(-(n+m).*z-kx,0,1);    
            q1 = (c+b.*t1).*t1 + d(~mask);          
            q2 = (c+b.*t2).*t2 + d(~mask);          
            res(~mask) = min( gdot2(q1), gdot2(q2) );
        % end
        res = realsqrt(res);                        %chk(res,[N,M],true );
    end
    function res = dist2bezier_arrayfun(pos,A,B,C)
    % adapted from https://iquilezles.org/articles/distfunctions2d/
        function c = gdot(a,b)
            c = real(conj(a).*b);
        end
        function c = gdot2(a)
            c = gdot(a,a);
        end
        function v = clamp(x,a,b)
            v = min(max(x,a),b);
        end
	    a = B - A;                              
        b = A - 2.0*B + C;                      
        c = a * 2.0;                            
        d = A - pos;                            
        kk = 1.0./gdot(b,b);                    
        kx = kk.*gdot(a,b);                     
        ky = kk.*(2.0*gdot(a,a)+gdot(d,b))/3.0; 
        kz = kk.*gdot(d,a);                     
        p = ky - kx.*kx;                        
        p3 = p.*p.*p;                           
        q = kx.*(2*kx.*kx-3*ky) + kz;           
        h = q.*q + 4*p3;                        
        res = 0; %#ok<NASGU> 
        if h >= 0.0
            h   = realsqrt(h);                  
            uv1 = nthroot(.5*( h-q),3);         
            uv2 = nthroot(.5*(-h-q),3);         
            t   = clamp( uv1+uv2-kx, 0, 1 );    
            res = gdot2((c + b.*t).*t + d);     
        else
            z   = realsqrt(-p);               
            v   = acos( q./(p.*z.*2) ) / 3;   
            m   = cos(v);                     
            n   = sin(v)*sqrt(3);             
            t1  = clamp( (m+m).*z-kx,0,1);    
            t2  = clamp(-(n+m).*z-kx,0,1);    
            q1  = (c+b.*t1).*t1 + d;          
            q2  = (c+b.*t2).*t2 + d;          
            res = min( gdot2(q1), gdot2(q2) );
        end
        res = realsqrt(res);                    
    end
    
    if isafun; fun = @dist2bezier_arrayfun;
    else;      fun = @dist2bezier_matrix;   end
    if ~iscplx
        fun = @(x,y,A,B,C) fun(complex(x,y),complex(A(1),A(2)),complex(B(1),B(2)),complex(C(1),C(2)));
    end
end

% function v = dist2bezierOld(x,y,b0,b1,b2)
%     function v = gdot(a,b)
%         v = dot(a,b,2);
%     end
%     function v = gdot2(a)
%         v = dot(a,a,2);
%     end
%     v = x*0;
%     for i=1:size(x,1); for j=1:size(x,2) %slow
%         p = [x(i,j) y(i,j)];
%         pb0 = p-b0; pb1 = p-b1; pb2 = p-b2;
%         a = gdot2(pb0-2*pb1+pb2);
%         b = 3*gdot(pb1-pb0, pb0-2*pb1+pb2);
%         c = 3*gdot2(pb0)  - 6*gdot(pb0,pb1) ...
%           + gdot(pb2,pb0) + 2*gdot2(pb1);
%         d = gdot(pb0,pb1-pb0);
%         t = roots([a,b,c,d]);
%         t = real(t(abs(imag(t))<1e-10));
%         t = [t(0<t & t<1); 0; 1];
%         if isempty(t); t = 0; end
%         d = gdot2(pb0.*(1-t).^2 + 2*pb1.*t.*(1-t) + pb2.*t.^2);
%         v(i,j) = min(sqrt(d));
%     end; end
%     %v=v+0.2*sin(100*x).*sin(100*y);
% end
%
