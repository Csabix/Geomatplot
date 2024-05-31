package GeomatPlot.Mem;

public abstract class PackableFloat {
    protected int lastSize = 0;
    public abstract float[] pack();
    public abstract int bytes();
}
