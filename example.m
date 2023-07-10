% Examples

%% Geogebra like triangle
clf;
g=Geomatplot; ylim([-0.4 0.6])
A=Point([0  0]);
B=Point([1  0]);
C=Point([.7 .5]);
Segment({A,B},'b');
Segment({B,C},'b');
Segment({C,A},'b');
Midpoint('S',{A,B,C});
Circle({A,B,C},'m--');
PerpendicularBisector({A,B},':');
PerpendicularBisector({B,C},':');
PerpendicularBisector({C,A},':');
AngleBisector({A,B,C},':');
AngleBisector({B,C,A},':');
AngleBisector({C,A,B},':');
disp(g);

%% Image
clf;
g=Geomatplot;
b0=Point('b0',[0.1 0.2],'r');
b1=Point('b1',[0.7 0.9],'r');
b2=Point('b2',[0.9 0.2],'r');
c1=Point('c1',[-.5 0],'k','MarkerSize',5);
c2=Point('c2',[1.5 1],'k');
bt = @(t,b0,b1,b2) b0.*(1-t).^2 + 2*b1.*t.*(1-t) + b2.*t.^2;
Curve(bt,{b0,b1,b2},'r');
Image(@bezdist,{b0,b1,b2},c1,c2);
colorbar;
disp(g);


function v = bezdist(x,y,b0,b1,b2)
    function v = gdot(a,b)
        v = dot(a,b,2);
    end
    function v = gdot2(a)
        v = dot(a,a,2);
    end
    v = x*0;
    for i=1:size(x,1); for j=1:size(x,2) %slow
        p = [x(i,j) y(i,j)];
        pb0 = p-b0; pb1 = p-b1; pb2 = p-b2;
        a = gdot2(pb0-2*pb1+pb2);
        b = 3*gdot(pb1-pb0, pb0-2*pb1+pb2);
        c = 3*gdot2(pb0)  - 6*gdot(pb0,pb1) ...
          + gdot(pb2,pb0) + 2*gdot2(pb1);
        d = gdot(pb0,pb1-pb0);
        t = roots([a,b,c,d]);
        t = real(t(abs(imag(t))<1e-10));
        %t = real(t(min(abs(imag(t)))==abs(imag(t))));
        t = [t(0<t & t<1); 0; 1];
        if isempty(t); t = 0; end
        d = gdot2(pb0.*(1-t).^2 + 2*pb1.*t.*(1-t) + pb2.*t.^2);
        v(i,j) = min(sqrt(d));
    end; end
end



