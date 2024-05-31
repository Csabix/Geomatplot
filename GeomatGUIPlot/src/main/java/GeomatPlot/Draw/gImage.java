package GeomatPlot.Draw;

import com.jogamp.opengl.GL4;
import com.jogamp.opengl.util.texture.Texture;
import com.jogamp.opengl.util.texture.TextureIO;

import java.io.File;
import java.util.Objects;

public class gImage extends Drawable{
    public Texture texture;
    private float aspect;
    private final String location;

    public float x;
    public float y;
    public float w;
    public float h;

    public gImage(String location, float x, float y, float width) {
        super(false);
        this.location = location;

        this.x = x;
        this.y = y;
        this.w = width;
        this.h = 0;
    }

    public void loadImage(GL4 gl) {
        try {
            texture = TextureIO.newTexture(new File(location), false);
            aspect = (float)texture.getImageWidth() / (float)texture.getImageHeight();
        } catch (Exception e) {
            System.out.println(e.getMessage());
            try {
                texture = TextureIO.newTexture(Objects.requireNonNull(getClass().getResourceAsStream("/fallbackImage.png")), false, "png");
                aspect = 1;
            } catch (Exception e2) {
                e2.printStackTrace();
            }
        }

        if(h == 0) {
            h = w/aspect;
        }
    }

    public void clear(GL4 gl) {
        texture.destroy(gl);
    }

    public void enforceAspect() {
        h = w/aspect;
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
        return DrawableType.Image;
    }
}
