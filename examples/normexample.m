%% Polygon Sphere trace
clf; disp 'Sphere Trace'


p = drawSliderX('p',[0.35 16],[-1,1.5],2);
ppi = Scalar(p,@(p) 2*gamma(1/p)^2/(p*gamma(2/p))); % value of pi :D
odeops = odeset('RelTol',1e-12,'AbsTol',1e-14);
quarterCircle = CustomValue(p,ppi,@(p,ppi) ode45(@(t,u) [-u(2)^(p-1);u(1)^(p-1)],[0 ppi/2],[1 0],odeops));
unitCircle = CustomValue(quarterCircle,@(pnorm) [pnorm.y , flip(pnorm.y,2).*[-1;1], pnorm.y.*[-1;-1] , flip(pnorm.y,2).*[1;-1]]');


% odeops = odeset('RelTol',1e-12,'AbsTol',1e-14);
% pnorm = ode45(@(t,u) [-u(2)^(p-1);u(1)^(p-1)],[0 ppi/2],[1 0],odeops);
% cospsinp = [pnorm.y , flip(pnorm.y,2).*[-1;1], pnorm.y.*[-1;-1] , flip(pnorm.y,2).*[1;-1]]';

% You can move, create, delete vertices of the following polygon:
f = Polygon([-1 0;1 0;1 1;0.7 0.7;0.3 0.5;0 0.9;-0.5 0.3;-1 0.3]);

p0 = Point('p0',[-.8,1.05],'r');    % ray start
q0 = Point('q0',[.5 ,0.90],'r',5);  % ray 'direction'
v0 = Eval((q0-p0)/pPointDistance(p,p0,q0)); % Operators: point-point=vector, vector/scalar = vector
Ray(p0,v0,'r',1.5)

pp = p0; n=10; % Sphere tracing illustration:
for i = 1:n
    d = pPolyDistance(p,pp,f); % distance to polygon yields a dependent scalar value
    pCircle(pp,d,p,'Color',[i/n 1-i/n 0])
    pp = (pp + v0*d)';   % vector*scalar=vector, point+vector=point, ' same as Eval
end

xlim([-1.6 1.3]); ylim([0 1.8]); axis off;

function pCircle2(unitCircle,A,r,varargin)
    SegmentSequence(unitCircle,A,r,@(cossin,A,r) A+r*cossin,0,varargin{:});
end

function pCircle(A,r,p,varargin)
    Curve(A,r,p,@(x,A,r,p) A+r.*[+x,+(1-abs(x).^p).^(1./p)],varargin{:});
    Curve(A,r,p,@(x,A,r,p) A+r.*[+x,-(1-abs(x).^p).^(1./p)],varargin{:});
    Curve(A,r,p,@(x,A,r,p) A+r.*[-x,+(1-abs(x).^p).^(1./p)],varargin{:});
    Curve(A,r,p,@(x,A,r,p) A+r.*[-x,-(1-abs(x).^p).^(1./p)],varargin{:});
end

function d = pPolyDistance(p,pp,poly)
    function d = callback(p,q,poly)
        xv = poly(:,1) - q(1); dx = diff(xv);
        yv = poly(:,2) - q(2); dy = diff(yv);
        d = inf; ops = optimset('MaxFunEvals',100,'MaxIter',100,'TolFun',1e-5,'TolX',1e-5);
        for i = 1:size(dx,1)
            [t] = fminbnd(@(t) abs(xv(i) + dx(i).*t).^p + abs(yv(i) + dy(i).*t).^p,0,1,ops);
            d = min(d,abs(xv(i) + dx(i).*t).^p + abs(yv(i) + dy(i).*t).^p);
        end
        d = d.^(1/p);
    end
    d = Scalar(p,pp,poly,@callback);
end

function d = pPointDistance(p,a,b)
    function d = callback(p,a,b)
        ab = a-b;
        d = (abs(ab(1)).^p +abs(ab(2)).^p).^(1/p);
    end
    d = Scalar(p,a,b,@callback);
end