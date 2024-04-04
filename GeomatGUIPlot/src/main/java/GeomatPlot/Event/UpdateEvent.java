package GeomatPlot.Event;

import GeomatPlot.AbstractWindow;
import GeomatPlot.Draw.Drawable;

import java.awt.AWTEvent;
import java.util.LinkedList;
import java.util.List;

public class UpdateEvent extends AWTEvent {
    public static final int UPDATE_EVENT = RESERVED_ID_MAX + 11;
    public List<Integer> IDs;
    public Drawable.DrawableType type;
    public UpdateEvent(AbstractWindow w, Drawable drawable) {
        super(w, UPDATE_EVENT);
        IDs = new LinkedList<>();
        IDs.add(drawable.getID());
        type = drawable.getType();
    }
    public void merge(UpdateEvent rhs) {
        if(rhs.type == type) {
            IDs.addAll(rhs.IDs);
        }
    }
}
