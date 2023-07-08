clf;
g=Geomatplot;
Point('A',[0 0]);
Point('B',[1 1]);
Midpoint('C',{'A','B'});
Segment('a',{'C','B'});
Midpoint('E',{'a'})