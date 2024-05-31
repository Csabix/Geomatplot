package GeomatPlot.Draw;

import GeomatPlot.ProgramObject;
import GeomatPlot.ProgramObjectBuilder;
import com.jogamp.opengl.GL4;

import java.util.ArrayList;
import java.util.List;

import static com.jogamp.opengl.GL.GL_TRIANGLES;

public class ImageDrawer extends Drawer{
    ProgramObject shader;

    public ImageDrawer(GL4 gl) {
        syncedDrawables = new ArrayList<>();

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Image.vert")
                .fragment("/Image.frag")
                .build();
    }

    @Override
    protected void syncInner(GL4 gl, int first, int last) {}

    @SuppressWarnings("unchecked")
    @Override
    protected void syncInner(GL4 gl, int start) {
        List<gImage> sublist = (List<gImage>)(Object)syncedDrawables.subList(start,syncedDrawables.size());
        for (gImage image:sublist) {
            image.loadImage(gl);
        }
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void drawInner(GL4 gl) {
        shader.use(gl);
        for (gImage image:(List<gImage>)(Object)syncedDrawables) {
            gl.glUniform1f(1,image.x);
            gl.glUniform1f(2,image.y);
            gl.glUniform1f(3,image.w);
            gl.glUniform1f(4,image.h);
            if(!image.texture.getMustFlipVertically()){
                gl.glUniform1i(5, 1);
            } else {
                gl.glUniform1i(5, 0);
            }

            gl.glBindTextureUnit(0, image.texture.getTextureObject());
            gl.glDrawArrays(GL_TRIANGLES, 0, 6);
        }
    }

    @Override
    protected void deleteInner(GL4 gl, int[] IDs) {
        for (int id:IDs) {
            ((gImage)syncedDrawables.get(id)).clear(gl);
        }
    }

    @Override
    public void clean(GL4 gl) {
        for (Drawable drawable:syncedDrawables) {
            ((gImage)drawable).clear(gl);
        }
        shader.delete(gl);
        syncedDrawables.clear();
    }

    @Override
    public DrawableType requiredType() {
        return DrawableType.Image;
    }
}
