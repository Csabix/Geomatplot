package GeomatPlot.Draw;

import GeomatPlot.*;
import GeomatPlot.Mem.ManagedFloatBuffer;
import GeomatPlot.Mem.PackableFloat;
import com.jogamp.opengl.GL4;

import java.util.ArrayList;
import java.util.List;

import static com.jogamp.opengl.GL3.GL_PROGRAM_POINT_SIZE;

public class PointDrawer extends Drawer{
    private static final int INITIAL_CAPACITY = 100 * gPoint.BYTES;
    private final ProgramObject shader;
    private final int vao;
    private final ManagedFloatBuffer pointBuffer;
    public PointDrawer(GL4 gl) {
        gl.glEnable(GL_PROGRAM_POINT_SIZE);
        drawableList = new ArrayList<>();

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Point.vert")
                .fragment("/Point.frag")
                .build();
        gl.glUniformBlockBinding(shader.ID,0,0);

        vao = GLObject.createVertexArrays(gl,1)[0];
        pointBuffer = new ManagedFloatBuffer(gl, INITIAL_CAPACITY);

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

        gl.glVertexArrayVertexBuffer(vao, 0, pointBuffer.buffer, 0, gPoint.BYTES);
    }
    public gPoint get(int index) {
        return (gPoint)drawableList.get(index);
    }

    @Override
    protected void syncInner(GL4 gl, Integer first, Integer last) {
        pointBuffer.update(gl, toPackableFloat(drawableList), first, last);
    }

    @Override
    protected void syncInner(GL4 gl) {
        pointBuffer.add(gl, toPackableFloat(drawableList.subList(syncedDrawable, drawableList.size())));
    }

    @Override
    protected void drawInner(GL4 gl) {
        shader.use(gl);
        gl.glUniform1i(shader.getUniformLocation(gl, "drawerID"), getDrawID());
        gl.glBindVertexArray(vao);
        gl.glDrawArrays(gl.GL_POINTS,0,syncedDrawable);
    }

    @Override
    protected void deleteInner(GL4 gl, int[] IDs) {
        int[] offsets = new int[IDs.length];

        for (int i = 0; i < IDs.length; ++i) {
            offsets[i] = IDs[i] * gPoint.BYTES;
        }

        pointBuffer.deleteRange(gl, offsets, gPoint.BYTES);
    }

    @Override
    public Drawable.DrawableType requiredType() {
        return Drawable.DrawableType.Point;
    }
}
