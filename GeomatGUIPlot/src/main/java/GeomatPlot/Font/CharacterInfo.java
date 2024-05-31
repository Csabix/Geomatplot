package GeomatPlot.Font;

public class CharacterInfo {
    public final int id;
    public final float u, v, w, h; // Top left corner, width, height in texture space
    public final float width, height; // width, height in pixels
    public CharacterInfo(Character character, CInfo info) {
        id = character;
        u = info.x0;
        v = info.y0;
        w = info.x1 - info.x0;
        h = info.y1 - info.y0;
        width = info.width;
        height = info.height;
    }
}
