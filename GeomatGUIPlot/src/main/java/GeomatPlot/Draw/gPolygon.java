package GeomatPlot.Draw;

import GeomatPlot.Plot;

public class gPolygon extends gPatch{
    public gPolygonPoint[] points;

    public gPolygon(float[] x, float[] y, int[][] indices, float[][] primaryColors, float[][] borderColors, float faceAlpha, boolean movable) {
        super(x, y, indices, primaryColors, borderColors, faceAlpha, movable);
    }

    public gPolygon(float[] x, float[] y, int[][] indices, boolean movable) {
        super(x, y, indices, movable);
    }

    public gPolygonPoint[] getPoints() {
        points = new gPolygonPoint[x.length];
        for (int i = 0; i < x.length; ++i) {
            points[i] = new gPolygonPoint(this, x[i], y[i], new float[]{0,0,1}, 10.f, true, i);
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
        for (int i = 0; i < points.length; i++) {
            points[i].x += dX;
            points[i].y += dY;
            plot.updateDrawable(points[i]);
        }
    }
}
