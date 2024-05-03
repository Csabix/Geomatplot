package GeomatPlot.Draw;

import GeomatPlot.Plot;

import java.util.Vector;
public class gPoint extends Drawable {
    public static final int ELEMENT_COUNT = 7;
    public static final int BYTES = ELEMENT_COUNT * Float.BYTES;
    public float x,y;
    public float[] primaryColor;
    public float width;
    public float type;
    public gPoint(float x, float y, float[] primaryColor, float width, float type, boolean movable) {
        super(movable);
        this.x = x;
        this.y = y;
        this.primaryColor = primaryColor;
        this.width = width;
        this.type = type;
    }
    public gPoint(float x, float y, boolean movable) {
        this(x,y, new float[]{0f, 0.4470f, 0.7410f}, 20f, 0f, movable);
    }
    public gPoint(float x, float y) {
        this(x, y, false);
    }
    @Override
    public float[] pack() {
        return new float[]{x,y,primaryColor[0],primaryColor[1],primaryColor[2], width,type};
    }

    @Override
    public int elementCount() {
        return ELEMENT_COUNT;
    }

    @Override
    public int bytes() {
        return BYTES;
    }

    @Override
    public DrawableType getType() {
        return DrawableType.Point;
    }

    @Override
    public void move(Plot plot, float dX, float dY) {
        this.x += dX;
        this.y += dY;
        plot.updateDrawable(this);
        notifyDrawable();
    }

    /*//MATLAB WTF
    private final Vector<Object> callbacks = new java.util.Vector<>();
    public synchronized void addMovingPointListener(MovingPointListener lis) {
        callbacks.addElement(lis);
    }
    public synchronized void removeMovingPointListener(MovingPointListener lis) {
        callbacks.removeElement(lis);
    }
    public interface MovingPointListener extends java.util.EventListener {
        void movingPoint(MovingPointEvent event);
    }
    public static class MovingPointEvent extends java.util.EventObject {
        private static final long serialVersionUID = 1L;
        public int id;
        MovingPointEvent(Object obj, int id) {
            super(obj);
            this.id = id;
        }
    }
    public void notifyPoint() {
        Vector dataCopy;
        synchronized(this) {
            dataCopy = (Vector)callbacks.clone();
        }
        for (int i=0; i < dataCopy.size(); i++) {
            MovingPointEvent event = new MovingPointEvent(this, getID());
            ((MovingPointListener)dataCopy.elementAt(i)).movingPoint(event);
        }
    }*/
}
