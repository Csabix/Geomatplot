package GeomatPlot.Draw;

import java.util.ArrayList;
import java.util.List;

public class gPolygon extends Drawable{
    public static final int ELEMENT_COUNT = 6;
    public static final int BYTE = ELEMENT_COUNT * Float.BYTES;

    public float[] x;
    public float[] y;
    public float faceAlpha;
    public float[][] primaryColors;
    public float[][] markerColors;
    public float[][] borderColors;
    public int[][] indices;

    public gPolygon(float[] x, float[] y, int[][] indices, float[][] primaryColors, float[][] markerColors, float[][] borderColors, float faceAlpha, boolean movable) {
        super(movable);
        this.x = x;
        this.y = y;
        this.primaryColors = primaryColors;
        this.markerColors = markerColors;
        this.borderColors = borderColors;
        this.indices = indices;
        this.faceAlpha = faceAlpha;
    }

    public gPolygon(float[] x, float[] y, int[][] indices, boolean movable) {
        this(x,y,indices,new float[][]{{0.466f, 0.674f, 0.188f}}, new float[][]{{0f,0.447f,0.741f}}, new float[][]{{0f,0f,0f}}, 1f, movable);
    }

    public List<gPoint> getPoints() {
        int mCD = markerColors.length;

        List<gPoint> points = new ArrayList<>(x.length);
        for (int i = 0; i < x.length; ++i) {
            points.add(new gPoint(x[i],y[i],markerColors[i % mCD], 10.f, 0.0f, isMovable()));
        }
        return points;
    }

    public gLine getLine() {
        float[] xL = new float[x.length+1];
        float[] yL = new float[x.length+1];
        for (int i = 0; i < x.length; i++) {
            xL[i] = x[i];
            yL[i] = y[i];
        }
        xL[x.length] = x[0];
        yL[y.length] = y[0];
        return new gLine(xL,yL,borderColors,new float[]{5.f}, false);
    }

    @Override
    public float[] pack() {
        int pCD = primaryColors.length;

        float[] result = new float[elementCount()];
        for (int i = 0; i < x.length; i++) {
            result[i * ELEMENT_COUNT    ] = primaryColors[i % pCD][0];
            result[i * ELEMENT_COUNT + 1] = primaryColors[i % pCD][1];
            result[i * ELEMENT_COUNT + 2] = primaryColors[i % pCD][2];
            result[i * ELEMENT_COUNT + 3] = faceAlpha;
            result[i * ELEMENT_COUNT + 4] = x[i];
            result[i * ELEMENT_COUNT + 5] = y[i];
        }
        return result;
    }

    @Override
    public int elementCount() {
        return x.length * ELEMENT_COUNT;
    }

    @Override
    public int elementCountVertex() {
        return ELEMENT_COUNT;
    }

    @Override
    public int bytes() {
        return x.length * BYTE;
    }

    @Override
    public int bytesVertex() {
        return BYTE;
    }

    @Override
    public DrawableType getType() {
        return DrawableType.Polygon;
    }
}
