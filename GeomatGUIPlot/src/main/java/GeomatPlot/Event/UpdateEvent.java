package GeomatPlot.Event;

import GeomatPlot.AbstractWindow;
import GeomatPlot.Draw.Drawable;
import GeomatPlot.Tuple;

import java.awt.AWTEvent;
import java.util.LinkedList;
import java.util.List;

public class UpdateEvent extends AWTEvent {
    public static final int UPDATE_EVENT = RESERVED_ID_MAX + 11;
    public List<Drawable> drawables;
    public Drawable.DrawableType type;

    public UpdateEvent(AbstractWindow w, Drawable drawable) {
        super(w, UPDATE_EVENT);
        drawables = new LinkedList<>();
        drawables.add(drawable);
        type = drawable.getType();
    }

    public void merge(UpdateEvent rhs) {
        if(rhs.type == type) {
            drawables.addAll(rhs.drawables);
        }
    }

    // [min, max[
    public Tuple<Integer, Integer> range() {
        int min = Integer.MAX_VALUE;
        int max = Integer.MIN_VALUE;
        for (Drawable drawable:drawables) {
            int id = drawable.getID();
            if(id > max) max = id;
            if(id < min) min = id;
        }
        return new Tuple<>(min,max+1);
    }
}
