package GeomatPlot.Draw;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.util.Arrays;

public class gPatch extends Drawable{
    public static final int ELEMENT_COUNT = 10;
    public static final int VERTEX_BYTE = ELEMENT_COUNT * Float.BYTES;

    public float[] x;
    public float[] y;
    public float[][] backgroundColors;
    public float[][] borderColors;
    public int[][] indices;

    public gPatch(float[] x, float[] y, float[][] bgColor, float[][] brColor, int[][] indices ) {
        super(false);
        this.x = x;
        this.y = y;
        backgroundColors = bgColor;
        borderColors = brColor;
        this.indices = indices;
    }
    public int[] flatIndices() {
        return Arrays.stream(indices).flatMapToInt(Arrays::stream).toArray();
    }
    @Override
    public float[] pack() {
        int bgD = backgroundColors.length;
        int brD = borderColors.length;
        float[] result = new float[x.length * 10];
        for (int i = 0; i < x.length; i++) {
            result[i * ELEMENT_COUNT]     = x[i];
            result[i * ELEMENT_COUNT + 1] = y[i];
            result[i * ELEMENT_COUNT + 2] = backgroundColors[i % bgD][0];
            result[i * ELEMENT_COUNT + 3] = backgroundColors[i % bgD][1];
            result[i * ELEMENT_COUNT + 4] = backgroundColors[i % bgD][2];
            result[i * ELEMENT_COUNT + 5] = backgroundColors[i % bgD][3];
            result[i * ELEMENT_COUNT + 6] = borderColors[i % brD][0];
            result[i * ELEMENT_COUNT + 7] = borderColors[i % brD][1];
            result[i * ELEMENT_COUNT + 8] = borderColors[i % brD][2];
            result[i * ELEMENT_COUNT + 9] = borderColors[i % brD][3];
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
        return x.length * VERTEX_BYTE;
    }
    @Override
    public int bytesVertex() {
        return VERTEX_BYTE;
    }
    @Override
    public DrawableType getType() {
        return Drawable.DrawableType.Patch;
    }
}
