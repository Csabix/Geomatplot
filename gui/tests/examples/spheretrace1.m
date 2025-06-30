%% Polygon Sphere trace
clf; disp 'Sphere Trace'

% You can move, create, delete vertices of the following polygon:
f = Polygon([-1 0;1 0;1 1;0.7 0.7;0.3 0.5;0 0.9;-0.5 0.3;-1 0.3]);

p0 = Point('p0',[-.8,1.05],'r');    % ray start
q0 = Point('q0',[.5 ,1.05],'r',5);  % ray 'direction'
v0 = Eval((q0-p0)/Distance(p0,q0)); % Operators: point-point=vector, vector/scalar = vector
Ray(p0,v0,'r',1.5)

p = p0; n=10; % Sphere tracing illustration:
for i = 1:n
    d = Distance(p,f); % distance to polygon yields a dependent scalar value
    Circle(p,d,'Color',[i/n 1-i/n 0])
    p = (p + v0*d)';   % vector*scalar=vector, point+vector=point, ' same as Eval
end