package GeomatPlot.Draw;

import GeomatPlot.Plot;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.util.Arrays;

public class gPatch extends Drawable{
    public static final int ELEMENT_COUNT = 6;
    public static final int BYTE = ELEMENT_COUNT * Float.BYTES;

    public float[] x;
    public float[] y;
    public float faceAlpha;
    public float[][] primaryColors;
    public float[][] borderColors;
    public int[][] indices;
    protected gPatchLine line;

    public gPatch(float[] x, float[] y, int[][] indices, float[][] primaryColors, float[][] borderColors, float faceAlpha, boolean movable) {
        super(movable);
        this.x = x;
        this.y = y;
        this.primaryColors = primaryColors;
        this.borderColors = borderColors;
        this.indices = indices;
        this.faceAlpha = faceAlpha;
    }

    public gPatch(float[] x, float[] y, int[][] indices, boolean movable) {
        this(x,y,indices,new float[][]{{0.466f, 0.674f, 0.188f}}, new float[][]{{0f,0f,0f}}, 1f, movable);
    }

    public gPatchLine getLine() {
        line = new gPatchLine(x,y,borderColors,5.f, this);
        return line;
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
    public int bytes() {
        return x.length * BYTE;
    }

    @Override
    public DrawableType getType() {
        return Drawable.DrawableType.Patch;
    }

    @Override
    public void move(Plot plot, float dX, float dY) {
        for (int i = 0; i < x.length; i++) {
            x[i] += dX;
            y[i] += dY;
            line.x[i] += dX;
            line.y[i] += dY;
        }
        plot.updateDrawable(this);
        notifyDrawable();
    }
}
