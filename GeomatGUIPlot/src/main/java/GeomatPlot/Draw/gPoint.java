package GeomatPlot.Draw;

import java.util.List;
import java.util.Vector;
public class gPoint extends Drawable {
    public static final int ELEMENT_COUNT = 8;
    public static final int BYTES = ELEMENT_COUNT * Float.BYTES;
    public float x,y;
    float r,g,b;
    float br,bg,bb;
    public gPoint(List<Float> xy, List<Float> rgb, List<Float> brgb) {
        x = xy.get(0);y = xy.get(1);
        r = rgb.get(0);g = rgb.get(1);b = rgb.get(2);
        br = brgb.get(0);bg = brgb.get(1);bb = brgb.get(2);
    }
    public gPoint(float[] data) {
        x = data[0];y = data[1];
        r = data[2];g = data[3];b = data[4];
        br = data[5];bg = data[6];bb = data[7];
    }
    public gPoint(){}
    @Override
    public float[] pack() {
        return new float[]{x,y,r,g,b,br,bg,bb};
    }

    @Override
    public int elementCount() {
        return ELEMENT_COUNT;
    }

    @Override
    public int elementCountVertex() {
        return ELEMENT_COUNT;
    }

    @Override
    public int bytes() {
        return BYTES;
    }

    @Override
    public int bytesVertex() {
        return BYTES;
    }

    @Override
    public DrawableType getType() {
        return DrawableType.Point;
    }

    //MATLAB WTF
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
    /*public void notifyPoint(int id) {
        Vector dataCopy;
        synchronized(this) {
            dataCopy = (Vector)callbacks.clone();
        }
        for (int i=0; i < dataCopy.size(); i++) {
            MovingPointEvent event = new MovingPointEvent(this, id);
            ((MovingPointListener)dataCopy.elementAt(i)).movingPoint(event);
        }
    }*/
    public void notifyPoint() {
        Vector dataCopy;
        synchronized(this) {
            dataCopy = (Vector)callbacks.clone();
        }
        for (int i=0; i < dataCopy.size(); i++) {
            MovingPointEvent event = new MovingPointEvent(this, getID());
            ((MovingPointListener)dataCopy.elementAt(i)).movingPoint(event);
        }
    }
}
