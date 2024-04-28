package GeomatPlot.Draw;

public class gPatchLine extends gLine{
    public static final int VERTEX_SIZE = 8;
    public static final int VERTEX_BYTE = VERTEX_SIZE * Float.BYTES;
    public gPatchLine(float[] x, float[] y, float[][] primaryColor, float width) {
        super(x, y, primaryColor, new float[]{width}, false);
    }

    @Override
    public float[] pack() {
        float[] result = super.pack();

        int colorDiv = primaryColor.length;
        int last = x.length - 1;

        result[0] = primaryColor[last % colorDiv][0];
        result[1] = primaryColor[last % colorDiv][1];
        result[2] = primaryColor[last % colorDiv][2];
        result[3] = width[0];

        result[4] = x[last];
        result[5] = y[last];

        result[6] = Float.NaN;
        //data[7] = ... ;

        int lastOffset = last * VERTEX_SIZE;
        result[lastOffset    ] = primaryColor[0][0];
        result[lastOffset + 1] = primaryColor[0][1];
        result[lastOffset + 2] = primaryColor[0][2];
        result[lastOffset + 3] = width[0];

        result[lastOffset + 4] = x[0];
        result[lastOffset + 5] = y[0];

        result[lastOffset + 6] = Float.NaN;
        //data[lastOffset + 7] = ... ;

        return result;
    }
}
