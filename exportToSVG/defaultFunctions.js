/**
 * 
 * needed functions
 * [x] midpoint_
 * [x] dist_point2pointseq
 * [x] perpendicular_bisector
 * [x] equidistpoint
 * [x] angle_bisector3
 * [x] angle_bisector4
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

// DONE
function perpendicular_bisector(a,b /*matrices from point's coordinates*/){
    return math.add(math.dotMultiply(math.multiply(math.subtract(a, b),math.matrixFromRows([0,1],[-1,0])), math.subtract(0.5, math.matrixFromColumns([-1e8,-1e4,0,1,1e4,1e8]))), math.multiply(math.add(a,b), 0.5));
}

// DONE
function equidistpoint(a,b,c /*three matrices from point's coordinates*/){
    let n = math.subtract(a, b);
    let m = math.subtract(b, c);
    return math.multiply(0.5, math.divide(math.matrixFromColumns(math.multiply(math.add(a,b),math.transpose(n)), math.multiply(math.add(b,c),math.transpose(m))), math.matrixFromColumns(n,m))) //0.5*[(a+b)*n' (b+c)*m']/[n;m]'
}

// DONE
function angle_bisector3(a,b,c /*three matrices from point's coordinates*/){
    let ab = math.subtract(a,b);
    let cb = math.subtract(c,b);
    return math.add(b, math.dotMultiply(math.add(math.divide(ab, math.sqrt(math.dot(math.transpose(ab),math.transpose(ab)))), math.divide(cb, math.sqrt(math.dot(math.transpose(cb),math.transpose(cb))))),math.matrixFromColumns([-1e8,-1e4,0,1,1e4,1e8])));
}

// DONE
function angle_bisector4(a,b,c,d){
    // let a = math.matrixFromRows([document.getElementById('A').getAttributeNS(null, 'cx'),document.getElementById('A').getAttributeNS(null, 'cy')]);
    // let b = math.matrixFromRows([document.getElementById('B').getAttributeNS(null, 'cx'),document.getElementById('B').getAttributeNS(null, 'cy')]);
    // let c = math.matrixFromRows([document.getElementById('C').getAttributeNS(null, 'cx'),document.getElementById('C').getAttributeNS(null, 'cy')]);
    // let d = math.matrixFromRows([document.getElementById('D').getAttributeNS(null, 'cx'),document.getElementById('D').getAttributeNS(null, 'cy')]);
    let na = math.multiply(math.subtract(b,a),math.matrixFromRows([0,1],[-1,0]));
    let nb = math.multiply(math.subtract(d,c),math.matrixFromRows([0,1],[-1,0]));
    let p0 = math.transpose(math.lusolve(math.matrixFromRows(na,nb), math.matrixFromRows(math.multiply(na,math.transpose(a)),math.multiply(nb, math.transpose(c)))));
    let v1 = math.add(math.divide(na,math.sqrt(math.multiply(na, math.transpose(na)).at(0)[0])), math.divide(nb,math.sqrt(math.multiply(nb, math.transpose(nb)).at(0)[0])));
    let v2 = math.multiply(v1, math.matrixFromRows([0,1],[-1,0]));
    let vv = math.add(p0,math.concat(math.dotMultiply(v1,math.matrixFromColumns([-1e8,-1e4,0,1,1e4,1e8])), math.matrixFromColumns([NaN],[NaN]),math.dotMultiply(v2,math.matrixFromColumns([-1e8,-1e4,0,1,1e4,1e8])), 0));
    let line = document.getElementById('angbi4');
    let segments = line.querySelectorAll('line');
    let j = 0;
    for (let i = 0; i < vv.length-1; ++i) {
        if ( isNaN(vv[i][0]) || isNaN(vv[i+1][0])){continue;}
        segments[j].setAttributeNS(null, 'x1', vv[i][0]);
        segments[j].setAttributeNS(null, 'y1', vv[i][1]);
        segments[j].setAttributeNS(null, 'x2', vv[i+1][0]);
        segments[j].setAttributeNS(null, 'y2', vv[i+1][1]);
        ++j;
    }
}