package GeomatPlot.Draw;

import GeomatPlot.Plot;

public class gPolygon extends gPatch{
    public gPolygonPoint[] points;

    public gPolygon(float[] x, float[] y, int[][] indices, float[][] primaryColors, float[][] borderColors, float faceAlpha, boolean movable/*, int[] notControlPoint*/) {
        super(x, y, indices, primaryColors, borderColors, faceAlpha, movable);
    }

    public gPolygon(float[] x, float[] y, int[][] indices, boolean movable) {
        super(x, y, indices, movable);
    }

    public gPolygonPoint[] getPoints() {
        points = new gPolygonPoint[x.length];
        int indx = 0;
        for (int i = 0; i < x.length; ++i) {
            points[indx++] = new gPolygonPoint(this, x[i], y[i], new float[]{0,0,1}, 10.f, true, i);
        }
        return points;
    }

    @Override
    public DrawableType getType() {
        return DrawableType.Polygon;
    }

    @Override
    public void move(Plot plot, float dX, float dY) {
        super.move(plot, dX, dY);
        for (gPolygonPoint point : points) {
            int id = point.getPolygonID();
            point.x = x[id];
            point.y = y[id];
        }
        plot.updateDrawable(points);
    }
}
