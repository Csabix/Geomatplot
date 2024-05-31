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
    public float[] pack(float x, float y, float offsetX, float offsetY) {
        float[] data = new float[ELEMENT_COUNT];
        // Top left in pixels
        data[0 ] = offset + offsetX;
        data[1 ] = offsetY;
        // Width height in pixels
        data[2 ] = info.width;
        data[3 ] = info.height;
        // Top left corner, width, height in texture space
        data[4 ] = info.u;
        data[5 ] = info.v;
        data[6 ] = info.w;
        data[7 ] = info.h;
        // Starting point in world space
        data[8 ] = x;
        data[9 ] = y;

        return data;
    }
}