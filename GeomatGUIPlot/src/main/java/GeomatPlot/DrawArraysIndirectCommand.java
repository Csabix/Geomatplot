package GeomatPlot;

import GeomatPlot.Mem.PackableInt;

public class DrawArraysIndirectCommand implements PackableInt {
    public static final int BYTES = 4 * Integer.BYTES;
    public int count;
    public int instanceCount;
    public int firstIndex;
    public int baseInstance;

    public DrawArraysIndirectCommand(int count, int instanceCount, int firstIndex, int baseInstance) {
        this.count = count;
        this.instanceCount = instanceCount;
        this.firstIndex = firstIndex;
        this.baseInstance = baseInstance;
    }

    public DrawArraysIndirectCommand(int count, int firstIndex) {
        this(count, 1, firstIndex, 0);
    }

    @Override
    public int[] pack() {
        return new int[]{count,instanceCount,firstIndex,baseInstance};
    }

    @Override
    public int bytes() {
        return BYTES;
    }
}
