package GeomatPlot.Draw;

import GeomatPlot.BufferHelper;
import GeomatPlot.GLObject;
import GeomatPlot.ProgramObject;
import GeomatPlot.ProgramObjectBuilder;
import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.List;

import static com.jogamp.opengl.GL3.GL_PROGRAM_POINT_SIZE;

public class PointDrawer extends Drawer{
    private static final int BYTES = new gPoint().bytesVertex();
    private static final int SIZE = new gPoint().elementCountVertex();
    private static final int INITIAL_CAPACITY = 100 * BYTES;
    private final ProgramObject shader;
    private final int vao;
    private final int vbo;
    private int capacity;
    private int position;
    public PointDrawer(GL4 gl) {
        gl.glEnable(GL_PROGRAM_POINT_SIZE);

        drawableList = new ArrayList<>();
        position = 0;
        capacity = PointDrawer.INITIAL_CAPACITY;

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Point.vert")
                .fragment("/Point.frag")
                .build();
        gl.glUniformBlockBinding(shader.ID,0,0);

        vao = GLObject.createVertexArrays(gl,1)[0];
        vbo = GLObject.createBuffers(gl,1)[0];

        gl.glNamedBufferData(vbo,capacity, null, gl.GL_STATIC_DRAW);

        gl.glEnableVertexArrayAttrib(vao,0);
        gl.glVertexArrayAttribBinding(vao,0,0);
        gl.glVertexArrayAttribFormat(vao, 0, 2, gl.GL_FLOAT, false, 0);

        gl.glEnableVertexArrayAttrib(vao, 1);
        gl.glVertexArrayAttribBinding(vao, 1, 0);
        gl.glVertexArrayAttribFormat(vao, 1, 3, gl.GL_FLOAT, false, 2 * Float.BYTES);

        gl.glEnableVertexArrayAttrib(vao, 2);
        gl.glVertexArrayAttribBinding(vao, 2, 0);
        gl.glVertexArrayAttribFormat(vao, 2, 3, gl.GL_FLOAT, false, 5 * Float.BYTES);

        gl.glVertexArrayVertexBuffer(vao, 0, vbo, 0, gPoint.BYTES);
    }
    public gPoint get(int index) {
        return (gPoint)drawableList.get(index);
    }
    @Override
    protected void syncInner(GL4 gl, List<Integer> IDs, Integer first, Integer last) {
        ByteBuffer bBuffer = gl.glMapNamedBufferRange(vbo,(long)first * BYTES,(long)(last - first + 1) * BYTES,gl.GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();
        IDs.stream().distinct().forEach((id) -> {
            fBuffer.position((id-first) * SIZE);
            fBuffer.put(drawableList.get(id).pack());
        });
        gl.glUnmapNamedBuffer(vbo);
    }

    @Override
    protected void syncInner(GL4 gl) {
        if(drawableList.size() * BYTES > capacity) {
            capacity = BufferHelper.getNewCapacity(capacity, drawableList.size() * BYTES);
            BufferHelper.resizeBuffer(gl,vbo,position,capacity, gl.GL_STATIC_DRAW);
        }
        ByteBuffer bBuffer = gl.glMapNamedBufferRange(vbo,position,(long)(drawableList.size() - syncedDrawable) * BYTES,gl.GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();
        drawableList.stream().skip(syncedDrawable).forEach((e)->fBuffer.put(e.pack()));
        gl.glUnmapNamedBuffer(vbo);
        position = drawableList.size() * BYTES;
    }

    @Override
    protected void drawInner(GL4 gl) {
        shader.use(gl);
        gl.glBindVertexArray(vao);
        gl.glDrawArrays(gl.GL_POINTS,0,syncedDrawable);
    }
}
