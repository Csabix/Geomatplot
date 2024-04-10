package GeomatPlot.Draw;

import GeomatPlot.BufferHelper;
import GeomatPlot.GLObject;
import GeomatPlot.ProgramObject;
import GeomatPlot.ProgramObjectBuilder;
import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.List;

import static com.jogamp.opengl.GL.GL_UNSIGNED_INT;

public class PolygonDrawer extends Drawer{
    private final int INITIAL_CAPACITY = 100 * gPolygon.VERTEX_BYTE;
    private final ProgramObject shader;
    private final int vao;
    private final int vbo;
    private int capacity;
    private int positionBytes;
    private int position;
    public PolygonDrawer(GL4 gl) {
        drawableList = new ArrayList<>();
        capacity = INITIAL_CAPACITY;
        position = 0;
        positionBytes = 0;

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Line.vert")
                .fragment("/Line.frag")
                .build();
        gl.glUniformBlockBinding(shader.ID,0,0);

        vao = GLObject.createVertexArrays(gl,1)[0];
        vbo = GLObject.createBuffers(gl,1)[0];

        gl.glNamedBufferData(vbo,capacity, null, gl.GL_STATIC_DRAW);

        gl.glEnableVertexArrayAttrib(vao,0);
        gl.glVertexArrayAttribBinding(vao,0,0);
        gl.glVertexArrayAttribFormat(vao, 0, 2, gl.GL_FLOAT, false, 0);

        gl.glVertexArrayVertexBuffer(vao, 0, vbo, 0, gPolygon.VERTEX_BYTE);
    }
    @Override
    protected void syncInner(GL4 gl, List<Integer> IDs, Integer first, Integer last) {
        int start = 0;
        int length = 0;
        for (int i = 0; i < first; i++) {
            start += drawableList.get(i).bytes();
        }
        for(int i = first; i <= last; ++i) {
            length += drawableList.get(i).bytes();
        }
        ByteBuffer bBuffer = gl.glMapNamedBufferRange(vbo,start,length,gl.GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();
        for (int i = first; i <= last ; i++) {
            fBuffer.put(drawableList.get(i).pack());
        }
        gl.glUnmapNamedBuffer(vao);
    }
    @Override
    protected void syncInner(GL4 gl) {
        int bytes = 0;
        for(int i = position; i < drawableList.size(); ++i) {
            bytes += drawableList.get(i).bytes();
        }
        if(positionBytes + bytes > capacity) {
            capacity = BufferHelper.getNewCapacity(capacity, positionBytes + bytes);
            BufferHelper.resizeBuffer(gl,vbo,positionBytes + bytes,capacity, gl.GL_STATIC_DRAW);
        }

        ByteBuffer bBuffer = gl.glMapNamedBufferRange(vbo,positionBytes,positionBytes + bytes,gl.GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();
        drawableList.stream().skip(position).forEach((e)->fBuffer.put(e.pack()));
        gl.glUnmapNamedBuffer(vbo);

        position = drawableList.size();
        positionBytes += bytes;
    }

    @Override
    protected void drawInner(GL4 gl) {
        gl.glUseProgram(shader.ID);
        gl.glBindVertexArray(vao);
        gl.glDrawElements(GL.GL_TRIANGLES, -1, GL_UNSIGNED_INT, 0);
    }
}
