/**
 * 
 * needed functions
 * [x] midpoint_
 * [x] dist_point2pointseq
 * [x] perpendicular_bisector
 * [x] equidistpoint
 * [x] angle_bisector3
 * [ ] angle_bisector4
 * [ ] closest_point2pointseq
 * [ ] closest_point2circle
 * [ ] closest_point2polyline
 * [ ] dist_point2circle
 * [ ] dist_point2polyline
 * [ ] mirror_point2point
 * [ ] mirror_point2segment
 * [ ] mirror_point2pointseq
 * [ ] mirror_point2circle
 * [ ] mirror_point2polyline
 * [ ] perpline2point
 * [ ] perpline2segment
 * 
 * [ ] Vectorokat meg kell oldani
 * [ ] Intersects ??
 * [ ] dcurve functions ??
 * [ ] internallcallback ??
 */

// dist_point2pointseq is already done +1 (needs to find out how to deal with matching the outputs)

// DONE
function midpoint_(list /*list of math.matrix (point coordinates)*/){
    let x = list[0];
    console.log(x);
    let n = math.size(x)[0];
    console.log(n);
    let v = math.mean(x, 0);
    console.log(v);
    for(let j = 1; j < list.length; ++j){
        x = list[j];
        let n1 = math.size(x)[0];
        v = math.add(math.multiply(v, (n/(n+n1))), math.multiply(math.mean(x, 0), (n1/(n+n1))))
        n = n + n1;
    }
    return v;
}

function perpendicular_bisector(a,b /*matrices from point's coordinates*/){
    return math.add(math.dotMultiply(math.multiply(math.subtract(a, b),math.matrixFromRows([0,1],[-1,0])), math.subtract(0.5, math.matrixFromColumns([-1e8,-1e4,0,1,1e4,1e8]))), math.multiply(math.add(a,b), 0.5));
}

// DONE
function equidistpoint(a,b,c /*three matrices from point's coordinates*/){
    let n = math.subtract(a, b);
    let m = math.subtract(b, c);
    return math.multiply(0.5, math.divide(math.matrixFromColumns(math.multiply(math.add(a,b),math.transpose(n)), math.multiply(math.add(b,c),math.transpose(m))), math.matrixFromColumns(n,m))) //0.5*[(a+b)*n' (b+c)*m']/[n;m]'
}

function angle_bisector3(a,b,c /*three matrices from point's coordinates*/){
    let ab = math.subtract(a,b);
    let cb = math.subtract(c,b);
    return math.add(b, math.dotMultiply(math.add(math.divide(ab, math.sqrt(math.dot(math.transpose(ab),math.transpose(ab)))), math.divide(cb, math.sqrt(math.dot(math.transpose(cb),math.transpose(cb))))),math.matrixFromColumns([-1e8,-1e4,0,1,1e4,1e8])));
}