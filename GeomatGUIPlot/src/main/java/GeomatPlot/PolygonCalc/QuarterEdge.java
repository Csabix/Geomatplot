package GeomatPlot.PolygonCalc;

import GeomatPlot.Draw.gPolygon;

public class QuarterEdge {
    public Vertex data;
    private QuarterEdge next;
    private QuarterEdge rot;
    public static QuarterEdge makeQuadEdge(Vertex start,Vertex end) {
        final QuarterEdge startEnd  = new QuarterEdge();
        final QuarterEdge leftRight = new QuarterEdge();
        final QuarterEdge endStart  = new QuarterEdge();
        final QuarterEdge rightLeft = new QuarterEdge();

        start.outgoing = startEnd;
        end.outgoing = endStart;
        startEnd.data = start;
        endStart.data = end;

        startEnd.rot = leftRight;
        leftRight.rot = endStart;
        endStart.rot = rightLeft;
        rightLeft.rot = startEnd;

        // normal edges are on different vertices,
        // and initially they are the only edges out
        // of each vertex
        startEnd.next = startEnd;
        endStart.next = endStart;

        // but dual edges share the same face,
        // so they point to one another
        leftRight.next = rightLeft;
        rightLeft.next = leftRight;

        return startEnd;
    }
    public static void splice(QuarterEdge a, QuarterEdge b) {
        swapNexts(a.next.rot, b.next.rot);
        swapNexts(a, b);
    }
    public static void swapNexts(QuarterEdge a, QuarterEdge b) {
        final QuarterEdge anext = a.next;
        a.next = b.next;
        b.next = anext;
    }
    public static QuarterEdge makeTriangle(Vertex a, Vertex b, Vertex c) {
        final QuarterEdge ab = QuarterEdge.makeQuadEdge(a, b);
        final QuarterEdge bc = QuarterEdge.makeQuadEdge(b, c);
        final QuarterEdge ca = QuarterEdge.makeQuadEdge(c, a);

        splice(ab.sym(), bc);
        splice(bc.sym(), ca);
        splice(ca.sym(), ab);

        return ab;
    }
    public static QuarterEdge connect(QuarterEdge a, QuarterEdge b) {
        final QuarterEdge newEdge = makeQuadEdge(a.dest(), b.data);
        splice(newEdge, a.lnext());
        splice(newEdge.sym(), b);
        return newEdge;
    }
    public static void sever(QuarterEdge edge) {
        splice(edge, edge.prev());
        splice(edge.sym(), edge.sym().prev());
    }
    public static QuarterEdge insertPoint(QuarterEdge polygonEdge, Vertex point) {
        final QuarterEdge firstSpoke = makeQuadEdge(polygonEdge.data, point);
        splice(firstSpoke, polygonEdge);
        QuarterEdge spoke = firstSpoke;
        do {
            spoke = connect(polygonEdge, spoke.sym());
            spoke.rot.data = null;
            spoke.tor().data = null;
            polygonEdge = spoke.prev();
        } while (polygonEdge.lnext() != firstSpoke);
        return firstSpoke;
    }
    public static void flip(QuarterEdge edge) {
        final QuarterEdge a = edge.prev();
        final QuarterEdge b = edge.sym().prev();
        splice(edge, a);
        splice(edge.sym(), b);
        splice(edge, a.lnext());
        splice(edge.sym(), b.lnext());
        edge.data = a.dest();
        edge.sym().data = b.dest();
    }
    public QuarterEdge next() {
        return next;
    }
    public QuarterEdge rot() {
        return rot;
    }
    public QuarterEdge sym() {
        return rot.rot;
    }
    public QuarterEdge tor() {
        return rot.rot.rot;
    }
    public QuarterEdge prev() {
        return rot.next.rot;
    }
    public QuarterEdge lnext() {
        return tor().next.rot;
    }
    public Vertex dest() {
        return sym().data;
    }
}
