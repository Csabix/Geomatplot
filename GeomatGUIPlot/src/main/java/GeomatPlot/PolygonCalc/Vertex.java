package GeomatPlot.PolygonCalc;

public class Vertex {
    public float x, y;
    public QuarterEdge outgoing;
    public Vertex minus(Vertex rhs) {
        Vertex v = new Vertex();
        v.x = x - rhs.x;
        v.y = y - rhs.y;
        return v;
    }
    public static int checkInsideTriangle(Vertex A, Vertex B, Vertex C, Vertex P) {
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
}
