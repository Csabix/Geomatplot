clf;
g=Geomatplot;
Point('A',[0 0]);
Point('B',[1 1]);
Point('C',[1 1]);
Segment({'A','B'});
Segment({'C','B'});
AngleBisector({'A','B','C'});
% Midpoint('D',{'A','B'});
% Segment('a',{'C','B'});
% Midpoint('E',{'a'});
% PerpendicularBisector({'E','C'});