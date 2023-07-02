clf;
ggb = geomatplot;
ggb.addPoint('b0',[0 0],'g');
ggb.addPoint('b1',[1 1],'b');
ggb.addPoint('b2',[0 2],'b');
ggb.addPoint('c1',[1 0],'r');
ggb.addPoint('c2',[2 0],'r');
t = linspace(0,1,1000)';

[X,Y] = meshgrid(t,t');
f = @(x) sqrt( (x(1)-X).^2 + (x(2)-Y).^2 );
ggb.drawImage({'b0'},f,[0 1],[0 1]);

bt = @(b0,b1,b2) b0.*(1-t).^2 + 2*b1.*(1-t).*t + b2.*t.^2;
ggb.drawLine({'b0','b1','b2'},bt,'Color','k');
ggb.drawLine({'b0','c1','c2'},bt,'Color','k');


