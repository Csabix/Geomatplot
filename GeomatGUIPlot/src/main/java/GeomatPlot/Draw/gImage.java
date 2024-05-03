package GeomatPlot.Draw;

import com.jogamp.opengl.GL4;
import com.jogamp.opengl.util.texture.Texture;
import com.jogamp.opengl.util.texture.TextureIO;

import java.io.File;
import java.io.IOException;

public class gImage extends Drawable{
    private Texture texture;
    private float aspect;
    private final String location;

    float[] x, y;

    public gImage(String location, boolean moveable, float x, float y, float width) {
        super(moveable);
        this.location = location;

        this.x = new float[]{x,width};
        this.y = new float[]{y};
    }

    public void loadImage(GL4 gl) {
        try {
            texture = TextureIO.newTexture(new File(location), false);
            aspect = (float)texture.getImageWidth() / (float)texture.getImageHeight();
        } catch (Exception e) {
            e.printStackTrace();
        }

        float width = x[1];

        float xN = x[0] - width / 2f;
        float xP = x[0] + width / 2f;

        float yN = y[0] - width / 2f;
        float yP = y[0] + width / 2f;

        x = new float[]{xN, xP, xN, xP};
        y = new float[]{yN, yN, yP, yP};
    }

    @Override
    public float[] pack() {
        return new float[0];
    }

    @Override
    public int elementCount() {
        return 0;
    }

    @Override
    public int bytes() {
        return 0;
    }

    @Override
    public DrawableType getType() {
        return null;
    }
}
