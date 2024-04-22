package GeomatPlot.Draw;

import GeomatPlot.BufferHelper;
import GeomatPlot.Event.CreateEvent;
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
import static com.jogamp.opengl.GL3ES3.GL_SHADER_STORAGE_BUFFER;

public class LabelDrawer extends Drawer {
    private static final int INITIAL_CAPACITY = 100 * new gLabel().bytesVertex();
    private final FontMap fontMap;
    private final ProgramObject shader;
    private final int ssbo;
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

        ssbo = GLObject.createBuffers(gl,1)[0];

        gl.glNamedBufferData(ssbo, capacity, null, GL_STATIC_DRAW);
        //gl.glBindBufferBase(GL_SHADER_STORAGE_BUFFER,2,ssbo);
    }
    @Override
    public void add(CreateEvent event) {
        super.add(event);
        if(event.type == requiredType())event.drawables.forEach(d -> ((gLabel)d).fontMap = fontMap);
        //drawableList.forEach(d -> ((gLabel)d).fontMap = fontMap);
    }
    @Override
    public void drawInner(GL4 gl) {
        gl.glBindBufferBase(GL_SHADER_STORAGE_BUFFER,1,ssbo);
        shader.use(gl);
        gl.glDrawArrays(GL_TRIANGLES,0,drawCount);
    }
    @Override
    public void syncInner(GL4 gl) {
        int bytes = 0;
        Iterator<Drawable> iterator = drawableList.stream().skip(syncedDrawable).iterator();
        while (iterator.hasNext()) {
            Drawable drawable = iterator.next();
            bytes += drawable.bytes();
            drawCount += ((gLabel)drawable).letterCount() * 6;
        }

        if(position + bytes > capacity) {
            capacity = BufferHelper.getNewCapacity(capacity, position + bytes);
            BufferHelper.resizeBuffer(gl,ssbo,position,capacity,GL_STATIC_DRAW);
        }

        ByteBuffer bBuffer = gl.glMapNamedBufferRange(ssbo,(long)position, (long)bytes, GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();

        iterator = drawableList.stream().skip(syncedDrawable).iterator();
        for (Iterator<Drawable> it = iterator; it.hasNext(); ) {
            fBuffer.put(it.next().pack());
        }

        gl.glUnmapNamedBuffer(ssbo);

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

        ByteBuffer bBuffer = gl.glMapNamedBufferRange(ssbo,pos,len, GL_MAP_WRITE_BIT);
        FloatBuffer fBuffer = bBuffer.asFloatBuffer();

        for (int i = first; i <= last; i++) {
            fBuffer.put(drawableList.get(i).pack());
        }

        gl.glUnmapNamedBuffer(ssbo);
    }

    @Override
    public Drawable.DrawableType requiredType() {
        return Drawable.DrawableType.Label;
    }
}
