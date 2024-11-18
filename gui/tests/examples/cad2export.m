clf; 
[scal1,p,txt1] = drawSliderX('p',[0.00000 4.00000],[0.00000 0.00000],0.50000,2.00000);
[scal2,a11,txt2] = drawSliderX('a11',[0.00000 4.00000],[0.00000 1.00000],0.40000,2.00000);
[scal3,a12,txt3] = drawSliderX('a12',[0.00000 1.00000],[0.50000 1.00000],0.40000,1.00000);
[scal4,a21,txt4] = drawSliderX('a21',[0.00000 1.00000],[0.00000 0.80000],0.40000,1.00000);
[scal5,a22,txt5] = drawSliderX('a22',[0.00000 1.00000],[0.50000 0.80000],0.40000,1.00000);
curve1 = Curve('curve1',scal1,scal2,scal3,scal4,scal5,@(t,p,a11,a12,a21,a22)fun([cos(2*pi*t),sin(2*pi*t)],p,[a11,a12;a21,a22]).*[cos(2*pi*t),sin(2*pi*t)],'-',1,'Color',[0 0 0]);

xlim([-4.22334 5.22642]); ylim([-4.06724 3.74270]);

function y = fun(x,p,A)
    y = x;
    for i=1:size(x,1)
        y(i,:) = norm(A*x(i,:)',p)./norm(x(i,:),p);
    end
end
