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
import static com.jogamp.opengl.GL2GL3.GL_PRIMITIVE_RESTART;
import static com.jogamp.opengl.GL3ES3.GL_SHADER_STORAGE_BUFFER;

// https://stackoverflow.com/questions/60440682/drawing-a-line-in-modern-opengl
// https://www.codeproject.com/articles/199525/drawing-nearly-perfect-2d-line-segments-in-opengl
// https://www.codeproject.com/Articles/226569/Drawing-polylines-by-tessellation

public class LineDrawer extends Drawer{
    private static final Integer INITIAL_CAPACITY = 100 * gLine.VERTEX_BYTE;
    private static final int INITIAL_INDEX_CAPACITY = 100;
    ProgramObject shader;
    private final int ssbo;
    private final int veo;
    private int capacity;
    private int position;
    private int lineCount;
    private int indCapacity;
    private int indPosition;
    private int nextIndex;
    public LineDrawer(GL4 gl) {
        //gl.glEnable(GL_PRIMITIVE_RESTART);
        //gl.glPrimitiveRestartIndex(-1);

        drawableList = new ArrayList<>();

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Line.vert")
                .fragment("/Line.frag")
                //.geometry("/Line.geom")
                .build();

        gl.glUniformBlockBinding(shader.ID,0,0);

        capacity = INITIAL_CAPACITY;
        position = 0;
        lineCount = 0;

        indCapacity = INITIAL_INDEX_CAPACITY;
        indPosition = 0;
        nextIndex = 0;

        int[] buffers = GLObject.createBuffers(gl,2);
        ssbo = buffers[0];
        veo  = buffers[1];
        gl.glNamedBufferData(ssbo,capacity,null,GL_STATIC_DRAW);
        gl.glNamedBufferData(veo,(long)indCapacity * Integer.BYTES, null, GL_STATIC_DRAW);

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
        int size = 0;
        int indSize = 0;
        for (int i = lineCount; i < drawableList.size(); i++) {
            size += drawableList.get(i).bytes();
            //indSize += (((gLine)drawableList.get(i)).x.length * 2) + 1;
            indSize += ((((gLine)drawableList.get(i)).x.length - 1) * 6);
        }

        if (position + size > capacity) {
            capacity = BufferHelper.getNewCapacity(capacity, position + size);
            BufferHelper.resizeBuffer(gl,ssbo,position,capacity,GL_STATIC_DRAW);
        }
        if (indPosition + indSize > indCapacity) {
            indCapacity = BufferHelper.getNewCapacity(indCapacity, indPosition + indSize);
            BufferHelper.resizeBuffer(gl,veo,indPosition * Integer.BYTES, indCapacity * Integer.BYTES,GL_STATIC_DRAW);
        }

        ByteBuffer bBuffer = gl.glMapNamedBufferRange(ssbo,position,size,GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();
        drawableList.stream().skip(lineCount).forEach((e)->fBuffer.put(e.pack()));
        gl.glUnmapNamedBuffer(ssbo);

        bBuffer = gl.glMapNamedBufferRange(veo,(long)indPosition * Integer.BYTES, (long)indSize * Integer.BYTES, GL_MAP_WRITE_BIT);
        IntBuffer iBuffer = bBuffer.asIntBuffer();

        /*for (int i = lineCount; i < drawableList.size(); i++) {
            nextIndex += 2;
            gLine current = (gLine)drawableList.get(i);
            int[] indices = new int[(current.x.length * 2) + 1];
            for (int j = 0; j < current.x.length * 2; j++) {
                indices[j] = nextIndex;
                nextIndex++;
            }
            indices[current.x.length * 2] = -1;
            nextIndex += 2;
            iBuffer.put(indices);
        }*/
        final int[] steps = new int[]{1,1,0,-1,2,-1};
        for (int i = lineCount; i < drawableList.size(); ++i) {
            nextIndex += 2;
            gLine current = (gLine)drawableList.get(i);
            int[] indices = new int[(current.x.length - 1) * 6];
            for (int j = 0; j < (current.x.length - 1) * 6; j++) {
                indices[j] = nextIndex;
                nextIndex += steps[j%6];
            }
            iBuffer.put(indices);
            nextIndex += 4;
        }

        gl.glUnmapNamedBuffer(veo);
        position += size;
        lineCount = drawableList.size();
        indPosition += indSize;
    }

    @Override
    protected void drawInner(GL4 gl) {
        shader.use(gl);
        gl.glBindBuffer(GL_ELEMENT_ARRAY_BUFFER,veo);
        gl.glDrawElements(GL_TRIANGLES,indPosition,GL_UNSIGNED_INT, 0);
    }
}
