package GeomatPlot.Draw;

public abstract class Drawable {
    //public enum DrawableType{Point,Line,Label,Polygon};
    public enum DrawableType{Patch,Polygon,Line, Label, Point};
    private int ID;
    private final boolean movable;
    protected Drawable(boolean movable) {
        this.movable = movable;
    }
    public void setID(int ID) {
        this.ID = ID;
    }
    public int getID() {
        return ID;
    }
    public abstract float[] pack();
    public abstract int elementCount(); // Total float count
    public abstract int elementCountVertex(); // Float count per vertex
    public abstract int bytes();
    public abstract int bytesVertex();
    public abstract DrawableType getType();
    public boolean isMovable() {
        return movable;
    }
}
