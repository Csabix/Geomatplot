package GeomatPlot.Draw;

import GeomatPlot.BufferHelper;
import GeomatPlot.Font.FontMap;
import GeomatPlot.GLObject;
import GeomatPlot.ProgramObject;
import GeomatPlot.ProgramObjectBuilder;
import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import static com.jogamp.opengl.GL.*;
public class LabelDrawer extends Drawer {
    private static final int INITIAL_CAPACITY = 100 * new gLabel().bytesVertex();
    private final FontMap fontMap;
    private final ProgramObject shader;
    private final int vao;
    private final int vbo;
    private int capacity;
    private int position;
    private int drawCount;
    public LabelDrawer(GL4 gl) {
        fontMap = new FontMap(gl);
        drawableList = new ArrayList<>();
        capacity = INITIAL_CAPACITY;
        position = 0;
        drawCount = 0;

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Letter.vert")
                .fragment("/Letter.frag")
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
        gl.glVertexArrayAttribFormat(vao, 1, 2, gl.GL_FLOAT, false, 2 * Float.BYTES);

        gl.glEnableVertexArrayAttrib(vao, 2);
        gl.glVertexArrayAttribBinding(vao, 2, 0);
        gl.glVertexArrayAttribFormat(vao, 2, 2, gl.GL_FLOAT, false, 4 * Float.BYTES);

        gl.glVertexArrayVertexBuffer(vao, 0, vbo, 0, 6 * Float.BYTES);
    }
    @Override
    public void add(List<Drawable> drawableList) {
        super.add(drawableList);
        drawableList.forEach(d -> ((gLabel)d).fontMap = fontMap);
    }
    @Override
    public void drawInner(GL4 gl) {
        shader.use(gl);
        gl.glBindVertexArray(vao);
        gl.glDrawArrays(GL_TRIANGLES,0,drawCount);
    }
    @Override
    public void syncInner(GL4 gl) {
        int bytes = 0;
        Iterator<Drawable> iterator = drawableList.stream().skip(syncedDrawable).iterator();
        while (iterator.hasNext()) {
            Drawable drawable = iterator.next();
            bytes += drawable.bytes();
            drawCount += drawable.bytes() / drawable.bytesVertex() * 6;
        }

        if(position + bytes > capacity) {
            capacity = BufferHelper.getNewCapacity(capacity, position + bytes);
            BufferHelper.resizeBuffer(gl,vbo,position,capacity,GL_STATIC_DRAW);
        }

        ByteBuffer bBuffer = gl.glMapNamedBufferRange(vbo,(long)position, (long)bytes, GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();

        iterator = drawableList.stream().skip(syncedDrawable).iterator();
        for (Iterator<Drawable> it = iterator; it.hasNext(); ) {
            fBuffer.put(it.next().pack());
        }

        gl.glUnmapNamedBuffer(vbo);

        position += bytes;
    }

    @Override
    public void syncInner(GL4 gl, List<Integer> IDs, Integer first, Integer last) {
        int pos = 0;
        int len = 0;
        Iterator<Drawable> iterator = drawableList.stream().limit(first).iterator();
        while (iterator.hasNext()) {
            pos += iterator.next().bytes();
        }
        iterator = drawableList.stream().skip(first).limit(last - first + 1).iterator();
        while (iterator.hasNext()) {
            len += iterator.next().bytes();
        }

        ByteBuffer bBuffer = gl.glMapNamedBufferRange(vbo,pos,len, GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();

        for (int i = first; i <= last; i++) {
            fBuffer.put(drawableList.get(i).pack());
        }

        gl.glUnmapNamedBuffer(vbo);
    }
}
