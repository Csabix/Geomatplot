package GeomatPlot.Draw;

import GeomatPlot.Plot;

import java.util.Arrays;

public class gPolygon extends gPatch{
    public gPolygonPoint[] points;
    public int[] notControlPoint;

    public gPolygon(float[] x, float[] y, int[][] indices, float[][] primaryColors, float[][] borderColors, float faceAlpha, boolean movable, int[] notControlPoint) {
        super(x, y, indices, primaryColors, borderColors, faceAlpha, movable);
        this.notControlPoint = notControlPoint;
    }

    public gPolygon(float[] x, float[] y, int[][] indices, float[][] primaryColors, float[][] borderColors, float faceAlpha, boolean movable) {
        this(x, y, indices, primaryColors, borderColors, faceAlpha, movable, new int[]{});
    }

    public gPolygon(float[] x, float[] y, int[][] indices, boolean movable) {
        super(x, y, indices, movable);
        this.notControlPoint = new int[]{};
    }

    public gPolygonPoint[] getPoints() {
        points = new gPolygonPoint[x.length - notControlPoint.length];
        int indx = 0;
        for (int i = 0; i < x.length; ++i) {
            boolean controlPoint = true;
            for (int j : notControlPoint) {
                if(i == j) {
                    controlPoint = false;
                    break;
                }
            }
            if(controlPoint)points[indx++] = new gPolygonPoint(this, x[i], y[i], new float[]{0,0,1}, 10.f, true, i);
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
