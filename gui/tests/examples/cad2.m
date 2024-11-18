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