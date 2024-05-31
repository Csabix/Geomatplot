package GeomatPlot.Mem;

import GeomatPlot.BufferHelper;
import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;
import java.nio.IntBuffer;
import java.util.List;

import static com.jogamp.opengl.GL.*;

public class ManagedIntBuffer extends BaseManagedBuffer{

    public ManagedIntBuffer(GL4 gl, int initialCapacity) {
        super(gl, initialCapacity);
    }

    public ManagedIntBuffer(GL4 gl) {
        this(gl, 100 * Integer.BYTES);
    }

    public void add(GL4 gl, List<PackableInt> elements) {
        if (elements.size() == 0) return;
        int bytes = 0;
        for(PackableInt e : elements) {
            bytes +=  e.bytes();
        }

        if(bytes + position >= capacity) {
            capacity = BufferHelper.getNewCapacity(capacity, bytes + position);
            BufferHelper.resizeBuffer(gl, buffer, position, capacity, GL_STATIC_DRAW);
        }

        ByteBuffer byteBuffer = gl.glMapNamedBufferRange(buffer, position, bytes, GL_MAP_WRITE_BIT);
        IntBuffer intBuffer = byteBuffer.asIntBuffer();
        elements.forEach((e) -> intBuffer.put(e.pack()));
        gl.glUnmapNamedBuffer(buffer);

        position += bytes;
    }

    public void add(GL4 gl, int[] elements) {
        int bytes = elements.length * Integer.BYTES;

        if(bytes + position > capacity) {
            capacity = BufferHelper.getNewCapacity(capacity, bytes + position);
            BufferHelper.resizeBuffer(gl, buffer, position, capacity, GL_STATIC_DRAW);
        }

        ByteBuffer byteBuffer = gl.glMapNamedBufferRange(buffer, position, bytes, GL_MAP_WRITE_BIT);
        IntBuffer intBuffer = byteBuffer.asIntBuffer();
        intBuffer.put(elements);
        gl.glUnmapNamedBuffer(buffer);

        position += bytes;
    }

    // [first, last]
    public void update(GL4 gl, List<PackableInt> elements, Integer first, Integer last) { // [first, last[
        int offset = 0;
        for(PackableInt e : elements.subList(0,first)) {
            offset += e.bytes();
        }

        List<PackableInt> updateRange = elements.subList(first,last);
        int bytes = 0;
        for(PackableInt e : updateRange) {
            bytes += e.bytes();
        }

        ByteBuffer byteBuffer = gl.glMapNamedBufferRange(buffer, offset, bytes, GL_MAP_WRITE_BIT);
        IntBuffer intBuffer = byteBuffer.asIntBuffer();

        offset = 0;
        for (PackableInt packableInt:updateRange) {
            if(packableInt.bytes() == packableInt.lastSize) {
                intBuffer.position(offset / Integer.BYTES);
                intBuffer.put(packableInt.pack());
            }
            offset += packableInt.lastSize;
        }

        gl.glUnmapNamedBuffer(buffer);
    }
}
