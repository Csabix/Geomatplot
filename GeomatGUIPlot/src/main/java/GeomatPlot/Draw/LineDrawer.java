package GeomatPlot.Draw;

import GeomatPlot.*;
import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.util.ArrayList;
import java.util.List;

import static com.jogamp.opengl.GL.*;
import static com.jogamp.opengl.GL3ES3.GL_DRAW_INDIRECT_BUFFER;
import static com.jogamp.opengl.GL3ES3.GL_SHADER_STORAGE_BUFFER;

// https://stackoverflow.com/questions/60440682/drawing-a-line-in-modern-opengl
// https://www.codeproject.com/articles/199525/drawing-nearly-perfect-2d-line-segments-in-opengl
// https://www.codeproject.com/Articles/226569/Drawing-polylines-by-tessellation

public class LineDrawer extends Drawer{
    private static final Integer INITIAL_CAPACITY = 100 * gLine.VERTEX_BYTE;
    private static final int INITIAL_INDIRECT_CAPACITY = 100;
    private static final int INDIRECT_STRUCT_BYTES = 4 * Integer.BYTES;
    ProgramObject shader;
    private final int ssbo;
    private final int indirect;
    private int capacity;
    private int position;
    private int indirectCapacity;
    private int indirectPosition;
    private int nextIndex;
    public LineDrawer(GL4 gl) {
        drawableList = new ArrayList<>();

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Line.vert")
                .fragment("/Line.frag")
                .build();

        gl.glUniformBlockBinding(shader.ID,0,0);

        capacity = INITIAL_CAPACITY;
        position = 0;

        indirectCapacity = INITIAL_INDIRECT_CAPACITY;
        indirectPosition = 0;
        nextIndex = 0;

        int[] buffers = GLObject.createBuffers(gl,2);
        ssbo = buffers[0];
        indirect  = buffers[1];
        gl.glNamedBufferData(ssbo,capacity,null,GL_STATIC_DRAW);
        gl.glNamedBufferData(indirect,(long)indirectCapacity * INDIRECT_STRUCT_BYTES, null, GL_STATIC_DRAW);

        gl.glBindBufferBase(GL_SHADER_STORAGE_BUFFER,1,ssbo);
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
        ByteBuffer bBuffer = gl.glMapNamedBufferRange(ssbo,start,length,gl.GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();
        for (int i = first; i <= last ; i++) {
            fBuffer.put(drawableList.get(i).pack());
        }
        gl.glUnmapNamedBuffer(ssbo);
    }

    @Override
    protected void syncInner(GL4 gl) {
        int bytes = 0;
        List<Tuple<Integer, Integer>> ranges = new ArrayList<>(drawableList.size() - indirectPosition);
        for (int i = indirectPosition; i < drawableList.size(); i++) {
            bytes += drawableList.get(i).bytes();
            int indSize = ((((gLine)drawableList.get(i)).x.length - 1) * 6);
            ranges.add(new Tuple<>(nextIndex, indSize));
            nextIndex += indSize + 18;
        }

        if (position + bytes > capacity) {
            capacity = BufferHelper.getNewCapacity(capacity, position + bytes);
            BufferHelper.resizeBuffer(gl,ssbo,position,capacity,GL_STATIC_DRAW);
        }
        if (indirectPosition + ranges.size() > indirectCapacity) {
            indirectCapacity = BufferHelper.getNewCapacity(indirectCapacity, indirectPosition + ranges.size());
            BufferHelper.resizeBuffer(gl,indirect,indirectPosition * Integer.BYTES, indirectCapacity * INDIRECT_STRUCT_BYTES,GL_STATIC_DRAW);
        }

        ByteBuffer bBuffer = gl.glMapNamedBufferRange(ssbo,position,bytes,GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();
        drawableList.stream().skip(indirectPosition).forEach((e)->fBuffer.put(e.pack()));
        gl.glUnmapNamedBuffer(ssbo);

        bBuffer = gl.glMapNamedBufferRange(indirect,(long)indirectPosition * INDIRECT_STRUCT_BYTES, (long)ranges.size() * INDIRECT_STRUCT_BYTES, GL_MAP_WRITE_BIT);
        IntBuffer iBuffer = bBuffer.asIntBuffer();
        ranges.forEach(tuple -> iBuffer.put(new int[]{tuple.second,1,tuple.first,0}));
        gl.glUnmapNamedBuffer(indirect);

        position += bytes;
        indirectPosition += ranges.size();
    }

    @Override
    protected void drawInner(GL4 gl) {
        shader.use(gl);
        gl.glUniform1i(shader.getUniformLocation(gl, "drawerID"), getDrawID());
        gl.glBindBuffer(GL_DRAW_INDIRECT_BUFFER, indirect);
        gl.glMultiDrawArraysIndirect(GL_TRIANGLES, 0, indirectPosition, 0);
    }

    @Override
    public Drawable.DrawableType requiredType() {
        return Drawable.DrawableType.Line;
    }
}
