package GeomatPlot.Draw;

import GeomatPlot.Plot;
import GeomatPlot.Tuple;

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
        Tuple<float[], float[]> points = getLinePositions();
        line = new gPatchLine(points.first, points.second, borderColors, 5.f, this);
        return line;
    }

    public void updateLine() {
        Tuple<float[], float[]> points = getLinePositions();
        line.update(points.first,points.second,borderColors,5.0f);
    }

    private Tuple<float[], float[]> getLinePositions() {
        // In case of self intersecting border
        float[] bX;
        float[] bY;
        if(indices.length == x.length - 2) {
            bX = x;
            bY = y;
        } else {
            int base = indices.length + 2;
            float[] xSub = new float[x.length - base];
            float[] ySub = new float[x.length - base];

            for (int i = 0; i < xSub.length; i++) {
                xSub[i] = x[i + base];
                ySub[i] = y[i + base];
            }

            bX = new float[base + xSub.length * 2];
            bY = new float[base + xSub.length * 2];

            int position = 0;
            for (int i = 0; i < base - 1; i++) {
                bX[position] = x[i];
                bY[position++] = y[i];

                for (int j = 0; j < xSub.length; j++) {
                    if(Math.abs(x[i] * (y[i+1] - ySub[j]) - y[i] * (x[i+1] - xSub[j])+x[i+1]*ySub[j]-y[i+1]*xSub[j]) < 1e-4) {
                        bX[position] = xSub[j];
                        bY[position++] = ySub[j];
                        break;
                    }
                }
            }
            bX[position] = x[base - 1];
            bY[position++] = y[base - 1];

            int i = base - 1;
            for (int j = 0; j < xSub.length; j++) {
                if(Math.abs(x[i] * (y[0] - ySub[j]) - y[i] * (x[0] - xSub[j])+x[0]*ySub[j]-y[0]*xSub[j]) < 1e-5) {
                    bX[position] = xSub[j];
                    bY[position] = ySub[j];
                    break;
                }
            }
        }
        return new Tuple<>(bX,bY);
    }

    @Override
    public float[] pack() {
        lastSize = bytes();
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
        return DrawableType.Patch;
    }

    @Override
    public void move(Plot plot, float dX, float dY) {
        for (int i = 0; i < x.length; i++) {
            x[i] += dX;
            y[i] += dY;
        }
        plot.updateDrawable(this);
        notifyDrawable();
    }
}
