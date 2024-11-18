clf; 
poly1 = Polygon('poly1',[-1.00000 0.00000; 1.00000 0.00000; 1.00000 1.00000; 0.70000 0.70000; 0.30000 0.50000; -0.22034 0.72795; -0.50000 0.30000; -1.00000 0.30000],[0 0 1]);
p0 = Point('p0',[-0.80000 1.05000],[1 0 0],8);
q0 = Point('q0',[0.50000 0.90000],[1 0 0],5);
[scal1,p,txt1] = drawSliderX('p',[0.35000 16.00000],[-1.00000 1.50000],2.00000,0.35000);
scal2 = Scalar('scal2',scal1,@(p)2*gamma(1/p)^2/(p*gamma(2/p)));
odeops = struct('AbsTol', 1e-14, 'BDF', [], 'Events', [], 'InitialStep', [], 'Jacobian', [], 'JConstant', [], 'JPattern', [], 'Mass', [], 'MassSingular', [], 'MaxOrder', [], 'MaxStep', [], 'NonNegative', [], 'NormControl', [], 'OutputFcn', [], 'OutputSel', [], 'Refine', [], 'RelTol', 1e-12, 'Stats', [], 'Vectorized', [], 'MStateDependence', [], 'MvPattern', [], 'InitialSlope', []);
custom1 = CustomValue('custom1',scal1,scal2,@(p,ppi)ode45(@(t,u)[-u(2)^(p-1);u(1)^(p-1)],[0,ppi/2],[1,0],odeops));
custom2 = CustomValue('custom2',custom1,@(pnorm)[pnorm.y,flip(pnorm.y,2).*[-1;1],pnorm.y.*[-1;-1],flip(pnorm.y,2).*[1;-1]]');
scal3 = Scalar('scal3',scal1,p0,q0,@pPointDistanceCallback);
expr1 = Eval('expr1',(q0-p0)/scal3);
ray1 = Ray('ray1',p0,expr1,'-',1.5,'Color',[1 0 0]);
scal4 = Scalar('scal4',scal1,p0,poly1,@pPolyDistanceCallback);
curve1 = Curve('curve1',p0,scal4,scal1,@(x,A,r,p)A+r.*[+x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.1 0.9 0]);
curve2 = Curve('curve2',p0,scal4,scal1,@(x,A,r,p)A+r.*[+x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.1 0.9 0]);
curve3 = Curve('curve3',p0,scal4,scal1,@(x,A,r,p)A+r.*[-x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.1 0.9 0]);
curve4 = Curve('curve4',p0,scal4,scal1,@(x,A,r,p)A+r.*[-x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.1 0.9 0]);
expr2 = Eval('expr2',p0+(expr1*scal4));
scal5 = Scalar('scal5',scal1,expr2,poly1,@pPolyDistanceCallback);
curve5 = Curve('curve5',expr2,scal5,scal1,@(x,A,r,p)A+r.*[+x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.2 0.8 0]);
curve6 = Curve('curve6',expr2,scal5,scal1,@(x,A,r,p)A+r.*[+x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.2 0.8 0]);
curve7 = Curve('curve7',expr2,scal5,scal1,@(x,A,r,p)A+r.*[-x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.2 0.8 0]);
curve8 = Curve('curve8',expr2,scal5,scal1,@(x,A,r,p)A+r.*[-x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.2 0.8 0]);
expr3 = Eval('expr3',expr2+(expr1*scal5));
scal6 = Scalar('scal6',scal1,expr3,poly1,@pPolyDistanceCallback);
curve9 = Curve('curve9',expr3,scal6,scal1,@(x,A,r,p)A+r.*[+x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.3 0.7 0]);
curve10 = Curve('curve10',expr3,scal6,scal1,@(x,A,r,p)A+r.*[+x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.3 0.7 0]);
curve11 = Curve('curve11',expr3,scal6,scal1,@(x,A,r,p)A+r.*[-x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.3 0.7 0]);
curve12 = Curve('curve12',expr3,scal6,scal1,@(x,A,r,p)A+r.*[-x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.3 0.7 0]);
expr4 = Eval('expr4',expr3+(expr1*scal6));
scal7 = Scalar('scal7',scal1,expr4,poly1,@pPolyDistanceCallback);
curve13 = Curve('curve13',expr4,scal7,scal1,@(x,A,r,p)A+r.*[+x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.4 0.6 0]);
curve14 = Curve('curve14',expr4,scal7,scal1,@(x,A,r,p)A+r.*[+x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.4 0.6 0]);
curve15 = Curve('curve15',expr4,scal7,scal1,@(x,A,r,p)A+r.*[-x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.4 0.6 0]);
curve16 = Curve('curve16',expr4,scal7,scal1,@(x,A,r,p)A+r.*[-x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.4 0.6 0]);
expr5 = Eval('expr5',expr4+(expr1*scal7));
scal8 = Scalar('scal8',scal1,expr5,poly1,@pPolyDistanceCallback);
curve17 = Curve('curve17',expr5,scal8,scal1,@(x,A,r,p)A+r.*[+x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.5 0.5 0]);
curve18 = Curve('curve18',expr5,scal8,scal1,@(x,A,r,p)A+r.*[+x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.5 0.5 0]);
curve19 = Curve('curve19',expr5,scal8,scal1,@(x,A,r,p)A+r.*[-x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.5 0.5 0]);
curve20 = Curve('curve20',expr5,scal8,scal1,@(x,A,r,p)A+r.*[-x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.5 0.5 0]);
expr6 = Eval('expr6',expr5+(expr1*scal8));
scal9 = Scalar('scal9',scal1,expr6,poly1,@pPolyDistanceCallback);
curve21 = Curve('curve21',expr6,scal9,scal1,@(x,A,r,p)A+r.*[+x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.6 0.4 0]);
curve22 = Curve('curve22',expr6,scal9,scal1,@(x,A,r,p)A+r.*[+x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.6 0.4 0]);
curve23 = Curve('curve23',expr6,scal9,scal1,@(x,A,r,p)A+r.*[-x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.6 0.4 0]);
curve24 = Curve('curve24',expr6,scal9,scal1,@(x,A,r,p)A+r.*[-x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.6 0.4 0]);
expr7 = Eval('expr7',expr6+(expr1*scal9));
scal10 = Scalar('scal10',scal1,expr7,poly1,@pPolyDistanceCallback);
curve25 = Curve('curve25',expr7,scal10,scal1,@(x,A,r,p)A+r.*[+x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.7 0.3 0]);
curve26 = Curve('curve26',expr7,scal10,scal1,@(x,A,r,p)A+r.*[+x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.7 0.3 0]);
curve27 = Curve('curve27',expr7,scal10,scal1,@(x,A,r,p)A+r.*[-x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.7 0.3 0]);
curve28 = Curve('curve28',expr7,scal10,scal1,@(x,A,r,p)A+r.*[-x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.7 0.3 0]);
expr8 = Eval('expr8',expr7+(expr1*scal10));
scal11 = Scalar('scal11',scal1,expr8,poly1,@pPolyDistanceCallback);
curve29 = Curve('curve29',expr8,scal11,scal1,@(x,A,r,p)A+r.*[+x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.8 0.2 0]);
curve30 = Curve('curve30',expr8,scal11,scal1,@(x,A,r,p)A+r.*[+x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.8 0.2 0]);
curve31 = Curve('curve31',expr8,scal11,scal1,@(x,A,r,p)A+r.*[-x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.8 0.2 0]);
curve32 = Curve('curve32',expr8,scal11,scal1,@(x,A,r,p)A+r.*[-x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.8 0.2 0]);
expr9 = Eval('expr9',expr8+(expr1*scal11));
scal12 = Scalar('scal12',scal1,expr9,poly1,@pPolyDistanceCallback);
curve33 = Curve('curve33',expr9,scal12,scal1,@(x,A,r,p)A+r.*[+x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.9 0.1 0]);
curve34 = Curve('curve34',expr9,scal12,scal1,@(x,A,r,p)A+r.*[+x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.9 0.1 0]);
curve35 = Curve('curve35',expr9,scal12,scal1,@(x,A,r,p)A+r.*[-x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.9 0.1 0]);
curve36 = Curve('curve36',expr9,scal12,scal1,@(x,A,r,p)A+r.*[-x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[0.9 0.1 0]);
expr10 = Eval('expr10',expr9+(expr1*scal12));
scal13 = Scalar('scal13',scal1,expr10,poly1,@pPolyDistanceCallback);
curve37 = Curve('curve37',expr10,scal13,scal1,@(x,A,r,p)A+r.*[+x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[1 0 0]);
curve38 = Curve('curve38',expr10,scal13,scal1,@(x,A,r,p)A+r.*[+x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[1 0 0]);
curve39 = Curve('curve39',expr10,scal13,scal1,@(x,A,r,p)A+r.*[-x,+(1-abs(x).^p).^(1./p)],'-',1,'Color',[1 0 0]);
curve40 = Curve('curve40',expr10,scal13,scal1,@(x,A,r,p)A+r.*[-x,-(1-abs(x).^p).^(1./p)],'-',1,'Color',[1 0 0]);
expr11 = Eval('expr11',expr10+(expr1*scal13));

xlim([-1.60000 1.30000]); ylim([0.00000 1.80000]);

function pCircle(go,A,r,p,varargin)
    Curve(go,A,r,p,@(x,A,r,p) A+r.*[+x,+(1-abs(x).^p).^(1./p)],varargin{:});
    Curve(go,A,r,p,@(x,A,r,p) A+r.*[+x,-(1-abs(x).^p).^(1./p)],varargin{:});
    Curve(go,A,r,p,@(x,A,r,p) A+r.*[-x,+(1-abs(x).^p).^(1./p)],varargin{:});
    Curve(go,A,r,p,@(x,A,r,p) A+r.*[-x,-(1-abs(x).^p).^(1./p)],varargin{:});
end

function pCircle2(unitCircle,A,r,varargin)
    SegmentSequence(go,unitCircle,A,r,@(cossin,A,r) A+r*cossin,0,varargin{:});
end

function d = pPointDistanceCallback(p,a,b)
        ab = a-b;
        d = (abs(ab(1)).^p +abs(ab(2)).^p).^(1/p);
end

function d = pPolyDistanceCallback(p,q,poly)
        xv = poly(:,1) - q(1); dx = diff(xv);
        yv = poly(:,2) - q(2); dy = diff(yv);
        d = inf; ops = optimset('MaxFunEvals',100,'MaxIter',100,'TolFun',1e-5,'TolX',1e-5);
        for i = 1:size(dx,1)
            [t] = fminbnd(@(t) abs(xv(i) + dx(i).*t).^p + abs(yv(i) + dy(i).*t).^p,0,1,ops);
            d = min(d,abs(xv(i) + dx(i).*t).^p + abs(yv(i) + dy(i).*t).^p);
        end
        d = d.^(1/p);
end
