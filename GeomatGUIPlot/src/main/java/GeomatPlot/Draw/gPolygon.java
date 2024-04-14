package GeomatPlot.Draw;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class gPolygon extends Drawable{
    public static final int VERTEX_SIZE = 2;
    public static final int VERTEX_BYTE = VERTEX_SIZE * Float.BYTES;
    public float[] x;
    public float[] y;
    public int[] indices;
    public gPolygon(float[] x, float[] y, int[] indices) {
        this.x = x;
        this.y = y;
        this.indices = indices;
    }
    @Override
    public float[] pack() {
        float[] result = new float[elementCount()];
        for (int i = 0; i < x.length; i++) {
            result[i * VERTEX_SIZE] = x[i];
            result[i * VERTEX_SIZE + 1] = y[i];
        }
        return result;
    }

    @Override
    public int elementCount() {
        return VERTEX_SIZE * x.length;
    }

    @Override
    public int elementCountVertex() {
        return VERTEX_SIZE;
    }

    @Override
    public int bytes() {
        return VERTEX_BYTE * x.length;
    }

    @Override
    public int bytesVertex() {
        return VERTEX_BYTE;
    }

    @Override
    public DrawableType getType() {
        return DrawableType.Polygon;
    }

}
