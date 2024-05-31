package GeomatPlot.Mem;

public abstract class PackableInt {
    protected int lastSize = 0;
    public abstract int[] pack();
    public abstract int bytes();
}
