package GeomatPlot.Draw;

import GeomatPlot.*;
import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.List;

import static com.jogamp.opengl.GL3.GL_PROGRAM_POINT_SIZE;

public class PointDrawer extends Drawer{
    private static final int INITIAL_CAPACITY = 100 * gPoint.BYTES;
    private final ProgramObject shader;
    private final int vao;
    private final ManagedDrawableBuffer vbo;
    public PointDrawer(GL4 gl) {
        gl.glEnable(GL_PROGRAM_POINT_SIZE);
        drawableList = new ArrayList<>();

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Point.vert")
                .fragment("/Point.frag")
                .build();
        gl.glUniformBlockBinding(shader.ID,0,0);

        vao = GLObject.createVertexArrays(gl,1)[0];
        vbo = new ManagedDrawableBuffer(gl, INITIAL_CAPACITY);

        gl.glEnableVertexArrayAttrib(vao,0);
        gl.glVertexArrayAttribBinding(vao,0,0);
        gl.glVertexArrayAttribFormat(vao, 0, 2, gl.GL_FLOAT, false, 0);

        gl.glEnableVertexArrayAttrib(vao, 1);
        gl.glVertexArrayAttribBinding(vao, 1, 0);
        gl.glVertexArrayAttribFormat(vao, 1, 3, gl.GL_FLOAT, false, 2 * Float.BYTES);

        gl.glEnableVertexArrayAttrib(vao, 2);
        gl.glVertexArrayAttribBinding(vao, 2, 0);
        gl.glVertexArrayAttribFormat(vao, 2, 1, gl.GL_FLOAT, false, 5 * Float.BYTES);

        gl.glEnableVertexArrayAttrib(vao, 3);
        gl.glVertexArrayAttribBinding(vao, 3, 0);
        gl.glVertexArrayAttribFormat(vao, 3, 1, gl.GL_FLOAT, false, 6 * Float.BYTES);

        gl.glVertexArrayVertexBuffer(vao, 0, vbo.buffer, 0, gPoint.BYTES);
    }
    public gPoint get(int index) {
        return (gPoint)drawableList.get(index);
    }
    @Override
    protected void syncInner(GL4 gl, List<Integer> IDs, Integer first, Integer last) {
        vbo.update(gl, drawableList, first, last);
    }

    @Override
    protected void syncInner(GL4 gl) {
        vbo.add(gl, drawableList.subList(syncedDrawable, drawableList.size()));
    }

    @Override
    protected void drawInner(GL4 gl) {
        shader.use(gl);
        gl.glUniform1i(shader.getUniformLocation(gl, "drawerID"), getDrawID());
        gl.glBindVertexArray(vao);
        gl.glDrawArrays(gl.GL_POINTS,0,syncedDrawable);
    }

    @Override
    public Drawable.DrawableType requiredType() {
        return Drawable.DrawableType.Point;
    }
}
