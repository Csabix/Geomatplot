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
import static com.jogamp.opengl.GL2ES2.GL_INT;

/*public class PolygonDrawer extends Drawer{
    private static final int INITIAL_INDIRECT_CAPACITY = 100 * 4 * Integer.BYTES;
    private final static int INITIAL_VBO_CAPACITY = 100 * gPolygon.POLY_DATA_BYTE;
    private final static int INITIAL_SSBO_CAPACITY = 100 * gPolygon.VERTEX_BYTE;
    private final static int INITIAL_EBO_CAPACITY = 100 * Integer.BYTES;
    // Programs
    private ProgramObject shader;
    private ProgramObject polyBorder;
    // VAOs
    private int vaoBorder;
    private int vaoBG = -1;
    private int vaoPoint = -1;
    // Buffers
    private int vbo;
    private int ebo;
    private int ssbo;
    private int indirect;
    // "Pointers"
    private int indirectCapacity;
    private int indirectPosition;
    private int vboCapacity;
    private int vboPosition;
    private int eboCapacity;
    private int eboPosition;
    private int ssboCapacity;
    private int ssboPosition;

    public PolygonDrawer(GL4 gl) {
        drawableList = new ArrayList<>();
        initShaders(gl);
        initBuffers(gl);
        initVAOs(gl);
    }
    private void initShaders(GL4 gl) {
        shader = new ProgramObjectBuilder(gl)
                .vertex("/Polygon.vert")
                .fragment("/Polygon.frag")
                .build();

        polyBorder = new ProgramObjectBuilder(gl)
                .vertex("/PolyBorder.vert")
                .fragment("/PolyBorder.frag")
                .build();

        gl.glUniformBlockBinding(shader.ID,0,0);
        gl.glUniformBlockBinding(polyBorder.ID,0,0);
    }
    private void initBuffers(GL4 gl) {
        // Indirect
        indirectCapacity = INITIAL_INDIRECT_CAPACITY;
        indirectPosition = 0;
        // Positions
        vboCapacity = INITIAL_VBO_CAPACITY;
        vboPosition = 0;
        // SSBO
        ssboCapacity = INITIAL_SSBO_CAPACITY;
        ssboPosition = 0;
        // EBO
        eboCapacity = INITIAL_EBO_CAPACITY;
        eboPosition = 0;

        int[] buffers = GLObject.createBuffers(gl,4);
        vbo = buffers[0];
        ssbo = buffers[1];
        indirect = buffers[2];
        ebo = buffers[3];

        gl.glNamedBufferData(indirect, indirectCapacity, null, GL_STATIC_DRAW);
        gl.glNamedBufferData(vbo, vboCapacity, null, GL_STATIC_DRAW);
        gl.glNamedBufferData(ssbo, ssboCapacity, null, GL_STATIC_DRAW);
        gl.glNamedBufferData(ebo, eboCapacity, null, GL_STATIC_DRAW);
    }
    private void initVAOs(GL4 gl) {
        int[] vaos = GLObject.createVertexArrays(gl, 3);
        vaoBG = vaos[0];
        vaoPoint = vaos[1];
        vaoBorder = vaos[2];

        // BG
        gl.glEnableVertexArrayAttrib(vaoBG,0);
        gl.glVertexArrayAttribBinding(vaoBG,0,0);
        gl.glVertexArrayAttribFormat(vaoBG, 0, 4, GL_FLOAT, false, 0);

        gl.glVertexArrayVertexBuffer(vaoBG, 0, vbo, 0, gPolygon.POLY_DATA_BYTE);
        gl.glVertexArrayElementBuffer(vaoBG, ebo);
        // Point
        gl.glEnableVertexArrayAttrib(vaoPoint,0);
        gl.glVertexArrayAttribBinding(vaoPoint,0,0);
        gl.glVertexArrayAttribFormat(vaoPoint, 0, 4, GL_FLOAT, false, 4 * Float.BYTES);

        gl.glEnableVertexArrayAttrib(vaoPoint,1);
        gl.glVertexArrayAttribBinding(vaoPoint,1,0);
        gl.glVertexArrayAttribFormat(vaoPoint, 1, 4, GL_FLOAT, false, 8 * Float.BYTES);

        gl.glVertexArrayVertexBuffer(vaoPoint, 0, vbo, 0, gPolygon.POLY_DATA_BYTE);
        // Border
        gl.glEnableVertexArrayAttrib(vaoPoint,0);
        gl.glVertexArrayAttribBinding(vaoPoint,0,0);
        gl.glVertexArrayAttribFormat(vaoPoint, 0, 4, GL_FLOAT, false, 12 * Float.BYTES);

        gl.glEnableVertexArrayAttrib(vaoPoint,0);
        gl.glVertexArrayAttribBinding(vaoPoint,1,0);
        gl.glVertexArrayAttribFormat(vaoPoint, 1, 1, GL_INT, false, 16 * Float.BYTES);

        gl.glEnableVertexArrayAttrib(vaoPoint,0);
        gl.glVertexArrayAttribBinding(vaoPoint,2,0);
        gl.glVertexArrayAttribFormat(vaoPoint, 2, 1, GL_INT, false, 16 * Float.BYTES + Integer.BYTES);

        gl.glVertexArrayVertexBuffer(vaoPoint, 0, vbo, 0, gPolygon.POLY_DATA_BYTE);
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
}*/

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
