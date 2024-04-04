package GeomatPlot.PolygonCalc;

import GeomatPlot.Tuple;

import java.util.ArrayList;
import java.util.List;

public class Delaunay {
    public List<Vertex> vertices;
    public List<Vertex> border;
    public Delaunay(List<Vertex> vertices) {
        this.vertices = vertices;
    }
    public void calc() {
        List<Vertex> bounds = boundingTriangle();
        border = bounds;
        QuarterEdge last = QuarterEdge.makeTriangle(bounds.get(0),bounds.get(1),bounds.get(2));
        for (Vertex v:vertices) {
            Tuple<QuarterEdge,inTriangleResult> resultTuple = findTriangle(last,v);
            if( resultTuple.second.inside == 0){
                // TODO if point on triangle
            }
            QuarterEdge.insertPoint(last,v);
        }
        //QuarterEdge
    }
    private Tuple<QuarterEdge,inTriangleResult> findTriangle(QuarterEdge last, Vertex p) {
        Vertex a = last.data; last = last.lnext();
        Vertex b = last.data; last = last.lnext();
        Vertex c = last.data; last = last.lnext();
        inTriangleResult result = pointInTriangle(a,b,c,p);
        if(result.inside >= 0) return new Tuple<QuarterEdge,inTriangleResult>(last,result);

        while(last.data != result.a) {
            last = last.lnext();
        }
        return findTriangle(last.prev(),p);
    }
    private List<Vertex> boundingTriangle() {
        float minX = Float.MAX_VALUE;
        float minY = Float.MAX_VALUE;
        float maxX = Float.MIN_VALUE;
        float maxY = Float.MIN_VALUE;
        float cX = 0;
        float cY = 0;
        for (Vertex v:vertices) {
            cX += v.x;
            cY += v.y;
            if(v.x > maxX) maxX = v.x;
            if(v.y > maxY) maxY = v.y;
            if(v.x < minX) minX = v.x;
            if(v.y < minY) minY = v.y;
        }
        cX /= (float) vertices.size();
        cY /= (float) vertices.size();
        float h = Math.abs(maxY - minY);
        float l = Math.abs(maxX - minX);

        List<Vertex> triangle = new ArrayList<>(3);
        Vertex left = new Vertex();
        left.x = cX - 2f * l;
        left.y = cY - h;
        triangle.add(left);

        Vertex right = new Vertex();
        right.x = cX + 2f * l;
        right.y = cY - h;
        triangle.add(right);

        Vertex top = new Vertex();
        top.x = cX;
        top.y = cY + 2f * h;
        triangle.add(top);

        return triangle;
    }
    // Counter clockwise
    // Left - , right +
    private float crossProductSign(Vertex a, Vertex b) {
        return a.x * b.y - a.y * b.x;
    }
    private class inTriangleResult {
        public int inside; // -1 outside, 0 on line, 1 inside
        // used when inside = -1/0
        public Vertex a;
        public Vertex b;
        public inTriangleResult(int inside, Vertex a, Vertex b){
            this.inside = inside;
            this.a = a;
            this.b = b;
        }
    }
    public inTriangleResult pointInTriangle(Vertex A, Vertex B, Vertex C, Vertex P) {
        Vertex AB = B.minus(A);
        Vertex BC = C.minus(B);
        Vertex CA = A.minus(C);
        Vertex AP = P.minus(A);
        Vertex BP = P.minus(B);
        Vertex CP = P.minus(C);

        float a = crossProductSign(AB,AP);
        if(a == 0) return new inTriangleResult(0, A, B);
        if(a > 0) return new inTriangleResult(-1, A, B);
        float b = crossProductSign(BC,BP);
        if(b == 0) return new inTriangleResult(0, B, C);
        if(b > 0) return new inTriangleResult(-1, B, C);
        float c = crossProductSign(CA,CP);
        if(c == 0) return new inTriangleResult(0, C, A);
        if(c > 0) return new inTriangleResult(-1, C, A);

        return new inTriangleResult(1, null, null);
    }
    public static int circleTest(Vertex A, Vertex B, Vertex C, Vertex P) {
        // Determinant of
        // Ax , Ay , Ax^2 + Ay^2 , 1
        // Bx , By , Bx^2 + By^2 , 1
        // Cx , Cy , Cx^2 + Cy^2 , 1
        // Px , Py , Px^2 + Py^2 , 1

        float AS = A.x*A.x + A.y*A.y;
        float BS = B.x*B.x + B.y*B.y;
        float CS = C.x*C.x + C.y*C.y;
        float PS = P.x*P.x + P.y*P.y;

        float det =A.x * det3x3(B.y, BS, 1.0f,
                C.y, CS, 1.0f,
                P.y, PS, 1.0f) -
                A.y * det3x3(B.x, BS, 1.0f,
                        C.x, CS, 1.0f,
                        P.x, PS, 1.0f) +
                AS  * det3x3(B.x, B.y, 1.0f,
                        C.x, C.y, 1.0f,
                        P.x, P.y, 1.0f) -
                det3x3(B.x,B.y,BS,
                        C.x,C.y,CS,
                        P.x,P.y,PS);

        return (int)Math.signum(det);
    }
    private static float det3x3(float a, float b, float c,
                                float d, float e, float f,
                                float g, float h, float i) {
        return a * det2x2(e,f,h,i) - b * det2x2(d,f,g,i) + c * det2x2(d,e,g,h);
    }
    private static float det2x2(float a, float b,
                                float c, float d) {
        return a * d - b * c;
    }
    public List<Vertex> triangulate() {
        List<Vertex> locked = new ArrayList<Vertex>();
        List<Vertex> result = new ArrayList<>();
        for (Vertex a:vertices) {
            QuarterEdge current = a.outgoing;
            QuarterEdge start = current;
            do {
                current = current.lnext();
                Vertex b = current.data;
                current = current.lnext();
                Vertex c = current.data;
                if(!border.contains(b) && !border.contains(b)){
                    if(!locked.contains(b) && !locked.contains(c)) {
                        result.add(a);
                        result.add(b);
                        result.add(c);
                    }
                }
                current = current.lnext().next();
            }while (current != start);
            locked.add(a);
        }
        return result;
    }
}
