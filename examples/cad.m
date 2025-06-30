clf; disp 'cad example'
n = 4; rng(1);
avals = rand(1,n)./(1:n);
pvals = rand(1,n)*2*pi;
ahs = {}; phs = {};

for i=1:n
    xpos = (i-1)/n*2*pi-pi;
    ahs{i} = drawSliderX("a"+int2str(i),[0,1   ],[xpos,1.4],1/n*1.8*pi,avals(i));
    phs{i} = drawSliderX("p"+int2str(i),[0,2*pi],[xpos,1.2],1/n*1.8*pi,pvals(i));
end

ah = CustomValue(ahs,@horzcat);
ph = CustomValue(phs,@horzcat);

graph = @(f,t,a,p) [t,f(t,a,p)];
f = @(t,a,p) sum(a.*sin(p + t.*2.^(1:n)),2);

Curve(ah, ph, @(t,a,p) graph(f,t*2*pi-pi,a,p),'b',2);

df = @(t,a,p) (f(t+0.0001,a,p)-f(t-0.0001,a,p))/0.0001;
g = @(t,a,p) f(t,a,p)./(df(t,a,p)<0);
Curve(ah, ph, @(t,a,p) graph(g,t*2*pi-pi,a,p),'r',3);

xlim([-pi pi]); ylim([-1 1.8])
%%
clf;
p = drawSliderX('p',[0 4],[0 0],0.5,2);
a11 = drawSliderX('a11',[0 4],[0 1],0.4,2);
a12 = drawSliderX('a12',[0 1],[0.5 1],0.4,2);
a21 = drawSliderX('a21',[0 1],[0 .8],0.4,2);
a22 = drawSliderX('a22',[0 1],[0.5 .8],0.4,2);
Curve(p,a11,a12,a21,a22,...
    @(t,p,a11,a12,a21,a22) fun([cos(2*pi*t),sin(2*pi*t)],p,[a11 a12; a21 a22]).*[cos(2*pi*t),sin(2*pi*t)]...
    );
function y = fun(x,p,A)
    y = x;
    for i=1:size(x,1)
        y(i,:) = norm(A*x(i,:)',p)./norm(x(i,:),p);
    end
end