%% Unit Disc
clf; disp 'Unit Disc'

orig = Point('orig',@() [0 0],'LabelV','off');
one1 = Scalar('one1',@() 1);
unitcircle = Circle(orig,one1,'m');

n = 5;
rng(0); ps=cell(n,1); is=ps;
for i = 1:n
    t = rand*2*pi; r = .5*rand+1.1;
    ps{i} = Point([cos(t) sin(t)]*r);
    is{i} = Mirror(ps{i}.label+"_", ps{i}, unitcircle,'c'); % 1/conj(a)
end

b = Point('b', [.5 0],'r');
ps = PointSequence(is{:});

Image(ps,@hipvoronoi,[-1 -1],[1 1]);
xlim([-1.5 1.5]); ylim([-1.5 1.5])

%%
function inds = hipvoronoi(z,pts) % z is a N*M matrix
    dist = inf(size(z));
    inds = z*0;
    for i=1:length(pts)
        tmp = abs(z-pts(i));
        mask = tmp<dist;
        dist(mask) = tmp(mask);
        inds(mask) = i;
    end
end

