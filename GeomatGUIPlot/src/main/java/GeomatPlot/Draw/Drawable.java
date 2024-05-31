package GeomatPlot.Draw;

import GeomatPlot.Mem.PackableFloat;
import GeomatPlot.Plot;

import java.util.Vector;

public abstract class Drawable extends PackableFloat implements Comparable<Drawable> {
    private int ID;
    private final boolean movable;
    protected Drawable(boolean movable) {
        this.movable = movable;
        this.ID = -1;
    }
    public void setID(int ID) {
        this.ID = ID;
    }
    public int getID() {
        return ID;
    }
    public abstract float[] pack();
    public abstract int elementCount(); // Total float count
    public abstract int bytes();
    public abstract DrawableType getType();
    public boolean isMovable() {
        return movable;
    }
    public void move(Plot plot, float dX, float dY) {
        throw new RuntimeException("Movement not supported");
    }

    @Override
    public int compareTo(Drawable drawable) {
        return Integer.compare(ID, drawable.ID);
    }

    //MATLAB Callback
    private final Vector<Object> callbacks = new java.util.Vector<>();
    public synchronized void addMovementListener(MovementListener lis) {
        callbacks.addElement(lis);
    }
    public synchronized void removeMovementListener(MovementListener lis) {
        callbacks.removeElement(lis);
    }
    public interface MovementListener extends java.util.EventListener {
        void movement(MovementEvent event);
    }
    public static class MovementEvent extends java.util.EventObject {
        private static final long serialVersionUID = 1L;
        public int id;
        MovementEvent(Object obj, int id) {
            super(obj);
            this.id = id;
        }
    }
    public void notifyDrawable() {
        Vector dataCopy;
        synchronized(this) {
            dataCopy = (Vector)callbacks.clone();
        }
        for (int i=0; i < dataCopy.size(); i++) {
            MovementEvent event = new MovementEvent(this, getID());
            ((MovementListener)dataCopy.elementAt(i)).movement(event);
        }
    }
}
