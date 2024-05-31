package GeomatPlot;

import GeomatPlot.Mem.PackableInt;

public class DrawElementsIndirectCommand extends PackableInt {
    // OpenGL draw command for indirect draw
    public static final int BYTES = 5 * Integer.BYTES;
    public int count;
    public int instanceCount;
    public int firstIndex;
    public int baseVertex;
    public int baseInstance;

    public DrawElementsIndirectCommand(int count, int instanceCount, int firstIndex, int baseVertex, int baseInstance) {
        this.count = count;
        this.instanceCount = instanceCount;
        this.firstIndex = firstIndex;
        this.baseVertex = baseVertex;
        this.baseInstance = baseInstance;
    }

    public DrawElementsIndirectCommand(int count, int firstIndex) {
        this(count, 1, firstIndex, 0, 0);
    }

    @Override
    public int[] pack() {
        return new int[]{count,instanceCount,firstIndex,baseVertex,baseInstance};
    }

    @Override
    public int bytes() {
        return BYTES;
    }
}
