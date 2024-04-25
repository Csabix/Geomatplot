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
import static com.jogamp.opengl.GL.GL_UNSIGNED_INT;

public class PatchDrawer extends Drawer{
    private final static int INITIAL_VBO_CAPACITY = 100 * gPatch.VERTEX_BYTE;
    private final static int INITIAL_EBO_CAPACITY = 100 * Integer.BYTES;
    private final static int INITIAL_IBO_CAPACITY = 100 * 5 * Float.BYTES;
    private final ProgramObject shader;
    private final int vao;
    private final int vbo;
    private final int ebo;
    private final int ibo;
    private int vboCapacity;
    private int eboCapacity;
    private int iboCapacity;
    private int vboPosition;
    private int eboPosition;
    private int iboPosition;
    public PatchDrawer(GL4 gl) {
        drawableList = new ArrayList<>();

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Polygon.vert")
                .fragment("/Polygon.frag")
                .build();
        gl.glUniformBlockBinding(shader.ID,0,0);

        vboCapacity = INITIAL_VBO_CAPACITY;
        eboCapacity = INITIAL_EBO_CAPACITY;
        iboCapacity = INITIAL_IBO_CAPACITY;

        vboPosition = 0;
        eboPosition = 0;
        iboPosition = 0;

        vao = GLObject.createVertexArrays(gl,1)[0];
        int[] buffers = GLObject.createBuffers(gl,3);
        vbo = buffers[0];
        ebo = buffers[1];
        ibo = buffers[2];

        gl.glNamedBufferData(vbo, vboCapacity, null, GL_STATIC_DRAW);
        gl.glNamedBufferData(ebo, eboCapacity, null, GL_STATIC_DRAW);
        gl.glNamedBufferData(ibo, iboCapacity, null, GL_STATIC_DRAW);


        gl.glEnableVertexArrayAttrib(vao,0);
        gl.glVertexArrayAttribBinding(vao,0,0);
        gl.glVertexArrayAttribFormat(vao, 0, 2, gl.GL_FLOAT, false, 0);

        gl.glEnableVertexArrayAttrib(vao,1);
        gl.glVertexArrayAttribBinding(vao,1,0);
        gl.glVertexArrayAttribFormat(vao, 1, 4, gl.GL_FLOAT, false, 2 * Float.BYTES);

        gl.glEnableVertexArrayAttrib(vao,2);
        gl.glVertexArrayAttribBinding(vao,2,0);
        gl.glVertexArrayAttribFormat(vao, 2, 4, gl.GL_FLOAT, false, 6 * Float.BYTES);

        gl.glVertexArrayVertexBuffer(vao, 0, vbo, 0, gPatch.VERTEX_BYTE);
        gl.glVertexArrayElementBuffer(vao, ebo);
    }
    @Override
    protected void syncInner(GL4 gl, List<Integer> IDs, Integer first, Integer last) {
        /*int start = 0;
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
        gl.glUnmapNamedBuffer(vao);*/
    }
    @Override
    protected void syncInner(GL4 gl) {
        int vertexCount = 0;
        int indCount = 0;
        for(int i = syncedDrawable; i < drawableList.size(); ++i) {
            vertexCount += ((gPatch)drawableList.get(i)).x.length;
            indCount += ((gPatch)drawableList.get(i)).indices.length;
        }
        // VBO resize
        if(vboPosition + vertexCount * gPatch.VERTEX_BYTE > vboCapacity) {
            vboCapacity = BufferHelper.getNewCapacity(vboCapacity, vboPosition + vertexCount * gPatch.VERTEX_BYTE);
            BufferHelper.resizeBuffer(gl,vbo,vboPosition + vertexCount * gPatch.VERTEX_BYTE, vboCapacity, GL_STATIC_DRAW);
        }
        // EBO resize
        if(eboPosition + indCount * Integer.BYTES > eboCapacity) {
            eboCapacity = BufferHelper.getNewCapacity(eboCapacity, eboPosition + indCount * Integer.BYTES);
            BufferHelper.resizeBuffer(gl,ebo,eboPosition + indCount * Integer.BYTES, eboCapacity, GL_STATIC_DRAW);
        }
        // IBO resize
        if(iboPosition + (drawableList.size() - syncedDrawable) * 5 * Float.BYTES > iboCapacity) {
            iboCapacity = BufferHelper.getNewCapacity(iboCapacity, iboPosition + (drawableList.size() - syncedDrawable) * 5 * Float.BYTES);
            BufferHelper.resizeBuffer(gl,ibo,iboPosition + (drawableList.size() - syncedDrawable) * 5 * Float.BYTES, iboCapacity, GL_STATIC_DRAW);
        }
        // VBO data
        ByteBuffer bBuffer = gl.glMapNamedBufferRange(vbo, vboPosition,(long)vertexCount * gPatch.VERTEX_BYTE, GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();
        drawableList.stream().skip(vboPosition / gPatch.VERTEX_BYTE).forEach((e)->fBuffer.put(e.pack()));
        gl.glUnmapNamedBuffer(vbo);
        // EBO data
        bBuffer = gl.glMapNamedBufferRange(ebo, eboPosition, (long)indCount * Integer.BYTES, GL_MAP_WRITE_BIT);
        IntBuffer iBuffer = bBuffer.asIntBuffer();
        drawableList.stream().skip(vboPosition / gPatch.VERTEX_BYTE).forEach((e)->iBuffer.put( ((gPatch)e).flatIndices() ));
        gl.glUnmapNamedBuffer(ebo);
        // IBO data
        bBuffer = gl.glMapNamedBufferRange(ibo, iboPosition, (long)(drawableList.size() - syncedDrawable) * 5 * Float.BYTES, GL_MAP_WRITE_BIT);
        IntBuffer iBuffer2 = bBuffer.asIntBuffer();
        int currentLength = eboPosition / Integer.BYTES;
        for (int i = syncedDrawable; i < drawableList.size(); i++) {
            gPatch current = (gPatch)drawableList.get(i);
            iBuffer2.put(new int[]{current.indices.length * 3, 1, currentLength, 0, 0});
            currentLength += current.indices.length * 3;
        }
        gl.glUnmapNamedBuffer(ibo);
        // Update positions
        vboPosition += vertexCount * gPatch.VERTEX_BYTE;
        eboPosition += indCount * Integer.BYTES;
        iboPosition += (drawableList.size() - syncedDrawable) * 5 * Float.BYTES;
    }
    @Override
    protected void drawInner(GL4 gl) {
        gl.glUseProgram(shader.ID);
        gl.glBindVertexArray(vao);
        gl.glDrawElements(GL_TRIANGLES, eboPosition, GL_UNSIGNED_INT, 0);
    }
    @Override
    public Drawable.DrawableType requiredType() {
        return Drawable.DrawableType.Patch;
    }
}
