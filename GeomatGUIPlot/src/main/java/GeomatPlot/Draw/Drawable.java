package GeomatPlot.Draw;

public abstract class Drawable {
    public enum DrawableType{Point,Line,Label,Polygon};
    private int ID;
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
}
