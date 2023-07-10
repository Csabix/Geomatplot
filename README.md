# Geomatplot

Geomatplot is a Matlab interactive plot library that is not unlike Geogebra.

## Main features

1. Interactive geometry library
2. Efficient update through the dependency graph
3. User defined callback functions for programming
4. Easy to use

## Requires
1. Image Processing Toolbox
2. Mapping Toolbox (for intersection)

## Geogebra-like example
```matlab
clf; Geomatplot; ylim([-0.4 0.6])
A = Point([0  0]); % draggable point, automatically labelled A
B = Point([1  0]); % automatic labels are applied if no label is given
C = Point([.7 .5]);
Segment({A,B},'b'); % a blue segment from A and B
Segment({B,C},'b');
Segment({C,A},'b');
Midpoint('S',{A,B,C}); % Barycenter of triangle labelled S
Circle({A,B,C},'m--'); % Magenta dashed circumcircle of the triangle
PerpendicularBisector({A,B},':');
PerpendicularBisector({B,C},':');
PerpendicularBisector({C,A},':');
AngleBisector({A,B,C},':');
AngleBisector({B,C,A},':');
AngleBisector({C,A,B},':');
```

![Interactive Triangle Plot](examples/triangle.png "Interactive Triangle Plot")

## Parametric curve and 2D function visualization
```matlab
clf; g = Geomatplot;
b0 = Point('b0',[0.1 0.2],'r'); % draggable control points
b1 = Point('b1',[0.7 0.9],'r'); % with given labels
b2 = Point('b2',[0.9 0.2],'r');
c1 = Point('c1',[-.5 0],'k','MarkerSize',5); % adjustable corner
c2 = Point('c2',[1.5 1],'k','MarkerSize',5); %   for the image
% parametric callback with t in [0,1] and dependent variables:
bt = @(t,b0,b1,b2)  b0.*(1-t).^2 + 2*b1.*t.*(1-t) + b2.*t.^2;
Curve(bt,{b0,b1,b2},'r'); % A red quadratic Bézier curve
Image(@dist2bezier,{b0,b1,b2},c1,c2); colorbar;
% where 'dist2bezier' is a (x,y,b0,b1,b2) -> real function
```

![Interactive Triangle Plot](examples/image.png "Interactive Triangle Plot")

### Query data

```
>> disp(g)
Geomatplot with 5 movable and 2 dependent plots:
 label : type     mean pos   |   labels : callback                                         
  'b0' : mpoint [0.10 0.20]  |          :                                                  
  'b1' : mpoint [0.70 0.90]  |          :                                                  
  'b2' : mpoint [0.90 0.20]  |          :                                                  
  'c1' : mpoint [-0.50 0.00] |          :                                                  
  'c2' : mpoint [1.50 1.00]  |          :                                                  
   'a' : dcurve [0.57 0.43]  | b0,b1,b2 : @(t,b0,b1,b2)b0.*(1-t).^2+2*b1.*t.*(1-t)+b2.*t.^2
   'A' : dimage [0.50 0.50]  | b0,b1,b2 : bezdist                                          
  Methods, Events, Superclasses
```