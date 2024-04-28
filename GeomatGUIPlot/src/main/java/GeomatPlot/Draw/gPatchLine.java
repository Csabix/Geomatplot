package GeomatPlot.Draw;

public class gPatchLine extends gLine{
    public static final int VERTEX_SIZE = 8;
    public static final int VERTEX_BYTE = VERTEX_SIZE * Float.BYTES;
    public final gPatch parent;
    public gPatchLine(float[] x, float[] y, float[][] primaryColor, float width, gPatch parent) {
        super(primaryColor, new float[]{width}, true);
        this.x = new float[x.length + 1];
        this.y = new float[y.length + 1];

        System.arraycopy(x,0,this.x,0,x.length);
        System.arraycopy(y,0,this.y,0,y.length);

        this.x[x.length] = x[0];
        this.y[y.length] = y[0];

        this.parent = parent;
    }

    @Override
    public float[] pack() {
        float[] result = super.pack();

        int last = x.length - 2;

        result[3] = width[0];
        result[4] = x[last];
        result[5] = y[last];
        result[6] = Float.NaN;

        int lastOffset = (x.length + 1) * VERTEX_SIZE;

        result[lastOffset + 3] = width[0];
        result[lastOffset + 4] = x[1];
        result[lastOffset + 5] = y[1];
        result[lastOffset + 6] = Float.NaN;

        return result;
    }
}
