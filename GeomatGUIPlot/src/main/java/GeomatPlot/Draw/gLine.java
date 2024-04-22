package GeomatPlot.Draw;

public class gLine extends Drawable {
    public static final int VERTEX_SIZE = 8;
    public static final int VERTEX_BYTE = VERTEX_SIZE * Float.BYTES;
    public float[] x;
    public float[] y;
    public float[][] colors;
    public boolean dashed;
    public gLine(float[] x, float[] y, float[][] colors, boolean dashed) {
        super(false);
        this.x = x;
        this.y = y;
        this.colors = colors;
        this.dashed = dashed;
    }
    public gLine(float[] x, float[] y, float[] colors, boolean dashed) {
        super(false);
        this.x = x;
        this.y = y;
        this.dashed = dashed;
        this.colors = new float[x.length][4];
        for (int i = 0; i < x.length; ++i) {
            System.arraycopy(colors,0,this.colors[i],0,4);
        }
    }

    @Override
    public float[] pack() {
        float[] data = new float[elementCount()];
        data[4] = x[0] + x[0] - x[1];
        data[5] = y[0] + y[0] - y[1];
        data[data.length - 4] = x[x.length - 1] + x[x.length - 1] - x[x.length - 2];
        data[data.length - 3] = y[y.length - 1] + y[y.length - 1] - y[y.length - 2];

        float distTotal = 0;
        for (int i = 1; i < x.length + 1; i++) {
            int ind = i - 1;
            data[i * VERTEX_SIZE    ] = colors[ind][0];
            data[i * VERTEX_SIZE + 1] = colors[ind][1];
            data[i * VERTEX_SIZE + 2] = colors[ind][2];
            data[i * VERTEX_SIZE + 3] = colors[ind][3];

            data[i * VERTEX_SIZE + 4] = x[ind];
            data[i * VERTEX_SIZE + 5] = y[ind];

            data[i * VERTEX_SIZE + 6] = distTotal;
            data[i * VERTEX_SIZE + 7] = dashed?10.0f:0.0f;

            if(ind < x.length - 1) {
                double dX = x[ind] - x[ind + 1];
                double dY = y[ind] - y[ind + 1];
                distTotal += (float)Math.sqrt(dX * dX + dY * dY);
            }
        }
        return data;
    }

    @Override
    public int elementCount() {
        return VERTEX_SIZE * (x.length + 2);
    }

    @Override
    public int elementCountVertex() {
        return VERTEX_SIZE;
    }

    @Override
    public int bytes() {
        return VERTEX_BYTE * (x.length + 2);
    }

    @Override
    public int bytesVertex() {
        return VERTEX_BYTE;
    }

    @Override
    public DrawableType getType() {
        return DrawableType.Line;
    }
}