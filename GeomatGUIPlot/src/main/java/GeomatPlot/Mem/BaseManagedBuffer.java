package GeomatPlot.Mem;

import GeomatPlot.GLObject;
import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;

import static com.jogamp.opengl.GL.*;

public class BaseManagedBuffer {
    public final int buffer;
    public int position, capacity;

    public BaseManagedBuffer(GL4 gl, int initialCapacity) {
        assert(initialCapacity != 0);
        capacity = initialCapacity;
        position = 0;
        buffer = GLObject.createBuffers(gl,1)[0];
        gl.glNamedBufferData(buffer, capacity, null, GL_STATIC_DRAW);
    }

    public void clear() {
        position = 0;
    }

    public void deleteRange(GL4 gl, int[] offsets, int range){
        int[] ranges = new int[offsets.length];
        Arrays.fill(ranges, range);
        deleteRange(gl, offsets, ranges);
    }
    public void deleteRange(GL4 gl, int[] offsets, int[] ranges) {
        assert(offsets.length == ranges.length);
        assert(offsets.length != 0);

        int byteTotal = 0;
        // Get base offset
        int baseOffset = Integer.MAX_VALUE;
        for (int offset : offsets) {
            if (offset < baseOffset) baseOffset = offset;
        }
        // Sort
        OffsetRange[] offsetRanges = new OffsetRange[offsets.length];
        for (int i = 0; i < offsets.length; ++i) {
            offsetRanges[i] = (new OffsetRange(offsets[i] - baseOffset,ranges[i]));
            byteTotal += ranges[i];
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
        merged.add(offsetRanges[currentIndex]);
        // Invert
        ArrayList<OffsetRange> inverted = new ArrayList<>(merged.size());
        for (int i = 1; i < merged.size(); i++) {
            OffsetRange left = merged.get(i - 1);
            OffsetRange right = merged.get(i);
            inverted.add(new OffsetRange(left.offset + left.range, right.offset - left.offset - left.range));
        }
        OffsetRange lastOffsetrange = merged.get(merged.size()-1);
        if(position - baseOffset - lastOffsetrange.offset - lastOffsetrange.range > 0)
            inverted.add(new OffsetRange(lastOffsetrange.offset + lastOffsetrange.range, position - baseOffset - lastOffsetrange.offset - lastOffsetrange.range));
        // Update buffer
        /*int maxPos = position - baseOffset;
        if(maxPos != 0) {
            ByteBuffer byteBuffer = gl.glMapNamedBufferRange(buffer, baseOffset, position - baseOffset, GL_MAP_READ_BIT | GL_MAP_WRITE_BIT);
            int currentPos = 0;
            for (OffsetRange current : inverted) {
                if (current.offset >= maxPos) continue;
                byte[] bytes = new byte[current.range];
                byteBuffer.position(current.offset);
                byteBuffer.get(bytes);
                byteBuffer.position(currentPos);
                byteBuffer.put(bytes);
                currentPos += current.range;
            }
        }*/

        ByteBuffer byteBuffer = gl.glMapNamedBufferRange(buffer, baseOffset, position - baseOffset, GL_MAP_READ_BIT | GL_MAP_WRITE_BIT);
        int currentPos = 0;
        for (OffsetRange current : inverted) {
            byte[] bytes = new byte[current.range];
            byteBuffer.position(current.offset);
            byteBuffer.get(bytes);
            byteBuffer.position(currentPos);
            byteBuffer.put(bytes);
            currentPos += current.range;
        }

        gl.glUnmapNamedBuffer(buffer);
        position -= byteTotal;
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
