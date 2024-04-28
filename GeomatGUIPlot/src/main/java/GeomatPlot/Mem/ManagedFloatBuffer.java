package GeomatPlot.Mem;

import GeomatPlot.BufferHelper;
import GeomatPlot.GLObject;
import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.util.*;

import static com.jogamp.opengl.GL.*;

public class ManagedFloatBuffer {
    public int capacity,position;
    public final int buffer;

    public void clear() {
        position = 0;
    }

    public ManagedFloatBuffer(GL4 gl, int initialCapacity) {
        capacity = initialCapacity;
        position = 0;
        buffer = GLObject.createBuffers(gl,1)[0];
        gl.glNamedBufferData(buffer, capacity, null, GL_STATIC_DRAW);
    }

    public ManagedFloatBuffer(GL4 gl) {
        this(gl, 100 * Float.BYTES);
    }

    public void add(GL4 gl, List<PackableFloat> elements) {
        int bytes = 0;
        for(PackableFloat e : elements) {
            bytes +=  e.bytes();
        }

        if(bytes + position > capacity) {
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

    public void deleteRange(GL4 gl, int[] offsets, int range){
        int[] ranges = new int[offsets.length];
        Arrays.fill(ranges, range);
        deleteRange(gl, offsets, ranges);
    }
    public void deleteRange(GL4 gl, int[] offsets, int[] ranges) {
        assert(offsets.length == ranges.length);
        assert(offsets.length != 0);
        // Get range
        int baseOffset = Integer.MAX_VALUE;
        for (int i = 0; i < offsets.length; ++i) {
            if(offsets[i] < baseOffset) baseOffset = offsets[i];
        }
        // Sort
        OffsetRange[] offsetRanges = new OffsetRange[offsets.length];
        for (int i = 0; i < offsets.length; ++i) {
            offsetRanges[i] = (new OffsetRange(offsets[i] - baseOffset,ranges[i]));
        }
        Arrays.sort(offsetRanges);
        // Merge
        ArrayList<OffsetRange> merged = new ArrayList<>(offsets.length);
        int currentIndex = 0;
        for (int i = 1; i < offsetRanges.length; ++i) {
            if(!offsetRanges[currentIndex].merge(offsetRanges[i])) {
                merged.add(offsetRanges[currentIndex]);
                currentIndex = i;
            }
        }
        if(currentIndex == offsetRanges.length - 1) {
            merged.add(offsetRanges[currentIndex]);
        } else {
            merged.add(offsetRanges[currentIndex]);
        }
        // Invert
        ArrayList<OffsetRange> inverted = new ArrayList<>(merged.size());
        for (int i = 1; i < merged.size(); i++) {
            OffsetRange left = merged.get(i - 1);
            OffsetRange right = merged.get(i);
            inverted.add(new OffsetRange(left.offset + left.range, right.offset - left.offset - left.range));
        }
        OffsetRange lastOffsetrange = merged.get(merged.size()-1);
        inverted.add(new OffsetRange(lastOffsetrange.offset + lastOffsetrange.range, position - lastOffsetrange.offset - lastOffsetrange.range));
        // Update buffer
        ByteBuffer byteBuffer = gl.glMapNamedBufferRange(buffer, baseOffset, position - baseOffset, GL_MAP_READ_BIT | GL_MAP_WRITE_BIT);
        int currentPos = 0;
        for (OffsetRange current : inverted) {
            byte[] bytes = new byte[current.range - baseOffset];
            byteBuffer.position(current.offset);
            byteBuffer.get(bytes);
            byteBuffer.position(currentPos);
            byteBuffer.put(bytes);
            currentPos += current.range;
        }

        gl.glUnmapNamedBuffer(buffer);
    }
    private static class OffsetRange implements Comparable<OffsetRange>{
        public Integer offset;
        public Integer range;
        public OffsetRange(int offset, int range) {
            this.offset = offset;
            this.range = range;
        }
        public boolean merge(OffsetRange rhs) {
            boolean merged = false;
            if(range + offset >= rhs.offset) {
                this.range = rhs.range + rhs.offset - offset;
                merged = true;
            }
            return merged;
        }

        @Override
        public int compareTo(OffsetRange offsetRange) {
            return this.offset.compareTo(offsetRange.offset);
        }
    }
}
