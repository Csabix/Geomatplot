package GeomatPlot.Mem;

import GeomatPlot.BufferHelper;
import GeomatPlot.GLObject;
import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.util.*;

import static com.jogamp.opengl.GL.*;

public class ManagedFloatBuffer extends BaseManagedBuffer{

    public ManagedFloatBuffer(GL4 gl, int initialCapacity) {
        super(gl, initialCapacity);
    }

    public ManagedFloatBuffer(GL4 gl) {
        this(gl, 100 * Float.BYTES);
    }

    public void add(GL4 gl, List<PackableFloat> elements) {
        int bytes = 0;
        for(PackableFloat e : elements) {
            bytes +=  e.bytes();
        }

        if(bytes + position >= capacity) {
            capacity = BufferHelper.getNewCapacity(capacity, bytes + position);
            BufferHelper.resizeBuffer(gl, buffer, position, capacity, GL_STATIC_DRAW);
        }

        ByteBuffer byteBuffer = gl.glMapNamedBufferRange(buffer, position, bytes, GL_MAP_WRITE_BIT);
        FloatBuffer floatBuffer = byteBuffer.asFloatBuffer();
        elements.forEach((e) -> floatBuffer.put(e.pack()));
        gl.glUnmapNamedBuffer(buffer);

        position += bytes;
    }

    // [first, last]
    public void update(GL4 gl, List<PackableFloat> elements, Integer first, Integer last) { // [first, last[
        int offset = 0;
        for(PackableFloat e : elements.subList(0,first)) {
            offset += e.bytes();
        }

        List<PackableFloat> updateRange = elements.subList(first,last);
        int bytes = 0;
        for(PackableFloat e : updateRange) {
            bytes += e.bytes();
        }

        ByteBuffer byteBuffer = gl.glMapNamedBufferRange(buffer, offset, bytes, GL_MAP_WRITE_BIT);
        FloatBuffer floatBuffer = byteBuffer.asFloatBuffer();
        updateRange.forEach((e) -> floatBuffer.put(e.pack()));
        gl.glUnmapNamedBuffer(buffer);
    }
}
