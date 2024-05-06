package GeomatPlot.Font;

public class Letter {
    public static final int ELEMENT_COUNT = 12; // vec4, vec4, vec2, vec2 (padding)
    public static final int BYTES = ELEMENT_COUNT * Float.BYTES;
    final CharacterInfo info;
    final float offset;
    public Letter(CharacterInfo c, float xOffset) {
        this.info = c;
        this.offset = xOffset;
    }
    public float[] pack(float x, float y, float oX, float oY) {
        float[] data = new float[ELEMENT_COUNT];
        data[0 ] = offset + oX;
        data[1 ] = oY;
        data[2 ] = info.width;
        data[3 ] = info.height;
        data[4 ] = info.u;
        data[5 ] = info.v;
        data[6 ] = info.w;
        data[7 ] = info.h;
        data[8 ] = x;
        data[9 ] = y;

        return data;
    }
}
/*public class Letter {
    public static final int ELEMENT_COUNT = 6 * 6;
    public static final int BYTES = ELEMENT_COUNT * Float.BYTES;
    final CharacterInfo info;
    final float offset;
    public Letter(CharacterInfo c, float xOffset) {
        this.info = c;
        this.offset = xOffset;
    }
    public float[] pack(float x, float y) {
        float[] data = new float[ELEMENT_COUNT];
        //A
        data[0 ] = x;
        data[1 ] = y;
        data[2 ] = offset;
        data[3 ] = 0;
        data[4 ] = info.u;
        data[5 ] = info.v;
        //B
        data[6 ] = x;
        data[7 ] = y;
        data[8 ] = offset;
        data[9 ] = -info.height;
        data[10] = info.u;
        data[11] = info.v + info.h;
        //C
        data[12] = x;
        data[13] = y;
        data[14] = offset + info.width;
        data[15] = -info.height;
        data[16] = info.u + info.w;
        data[17] = info.v + info.h;
        //C
        data[18] = x;
        data[19] = y;
        data[20] = offset + info.width;
        data[21] = -info.height;
        data[22] = info.u + info.w;
        data[23] = info.v + info.h;
        //D
        data[24] = x;
        data[25] = y;
        data[26] = offset + info.width;
        data[27] = 0;
        data[28] = info.u + info.w;
        data[29] = info.v;
        //A
        data[30] = x;
        data[31] = y;
        data[32] = offset;
        data[33] = 0;
        data[34] = info.u;
        data[35] = info.v;
        return data;
    }
}*/
