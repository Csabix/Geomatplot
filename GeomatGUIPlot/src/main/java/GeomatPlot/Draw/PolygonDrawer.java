package GeomatPlot.Draw;

import GeomatPlot.BufferHelper;
import GeomatPlot.GLObject;
import GeomatPlot.ProgramObject;
import GeomatPlot.ProgramObjectBuilder;
import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.util.ArrayList;
import java.util.List;

import static com.jogamp.opengl.GL.*;

public class PolygonDrawer extends Drawer{
    private final static int INITIAL_CAPACITY = 100 * gPolygon.VERTEX_BYTE;
    private final static int INITIAL_EBO_CAPACITY = 100;
    private final ProgramObject shader;
    private final int vao;
    private final int vbo;
    private final int ebo;
    private int capacity;
    private int eboCapacity;
    private int eboPosition;
    private int positionBytes;
    private int position;
    public PolygonDrawer(GL4 gl) {
        drawableList = new ArrayList<>();
        capacity = INITIAL_CAPACITY;
        eboCapacity = INITIAL_EBO_CAPACITY;
        position = 0;
        positionBytes = 0;
        eboPosition = 0;

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Polygon.vert")
                .fragment("/Polygon.frag")
                .build();
        gl.glUniformBlockBinding(shader.ID,0,0);

        int[] buffers = GLObject.createBuffers(gl,2);
        vao = GLObject.createVertexArrays(gl,1)[0];
        vbo = buffers[0];
        ebo = buffers[1];

        gl.glNamedBufferData(vbo,capacity, null, GL_STATIC_DRAW);
        gl.glNamedBufferData(ebo, (long)eboCapacity * Integer.BYTES, null, GL_STATIC_DRAW);

        gl.glEnableVertexArrayAttrib(vao,0);
        gl.glVertexArrayAttribBinding(vao,0,0);
        gl.glVertexArrayAttribFormat(vao, 0, 2, gl.GL_FLOAT, false, 0);

        gl.glVertexArrayVertexBuffer(vao, 0, vbo, 0, gPolygon.VERTEX_BYTE);
        gl.glVertexArrayElementBuffer(vao, ebo);
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
        int indexCount = 0;
        for(int i = position; i < drawableList.size(); ++i) {
            bytes += drawableList.get(i).bytes();
            indexCount += ((gPolygon)drawableList.get(i)).indices.length;
        }
        if(positionBytes + bytes > capacity) {
            capacity = BufferHelper.getNewCapacity(capacity, positionBytes + bytes);
            BufferHelper.resizeBuffer(gl,vbo,positionBytes + bytes,capacity, GL_STATIC_DRAW);
        }
        if(eboPosition + indexCount > eboCapacity) {
            eboCapacity = BufferHelper.getNewCapacity(eboCapacity, eboPosition + indexCount);
            BufferHelper.resizeBuffer(gl,ebo, eboPosition * Integer.BYTES, (eboPosition + indexCount) * Integer.BYTES, GL_STATIC_DRAW);
        }

        ByteBuffer bBuffer = gl.glMapNamedBufferRange(vbo,positionBytes,positionBytes + bytes, GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();
        drawableList.stream().skip(position).forEach((e)->fBuffer.put(e.pack()));
        gl.glUnmapNamedBuffer(vbo);

        bBuffer = gl.glMapNamedBufferRange(ebo, (long)eboPosition * Integer.BYTES, (long)indexCount * Integer.BYTES, GL_MAP_WRITE_BIT);
        IntBuffer iBuffer = bBuffer.asIntBuffer();
        drawableList.stream().skip(position).forEach((e)->iBuffer.put( ((gPolygon)e).indices ));
        gl.glUnmapNamedBuffer(ebo);

        position = drawableList.size();
        positionBytes += bytes;
        eboPosition += indexCount;
    }

    @Override
    protected void drawInner(GL4 gl) {
        gl.glUseProgram(shader.ID);
        gl.glBindVertexArray(vao);
        gl.glDrawElements(GL_TRIANGLES, eboPosition, GL_UNSIGNED_INT, 0);
    }

    @Override
    public Drawable.DrawableType requiredType() {
        return Drawable.DrawableType.Polygon;
    }
}
