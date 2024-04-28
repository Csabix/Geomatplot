package GeomatPlot.Event;

import GeomatPlot.AbstractWindow;
import GeomatPlot.Draw.Drawable;

import java.awt.AWTEvent;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

public class DeleteEvent extends AWTEvent {
    public static final int DELETE_EVENT = RESERVED_ID_MAX + 12;
    public List<Drawable> drawables;
    public Drawable.DrawableType type;

    public DeleteEvent(AbstractWindow w, Drawable drawable) {
        super(w, DELETE_EVENT);
        drawables = new LinkedList<>();
        drawables.add(drawable);
        type = drawable.getType();
    }

    public void merge(DeleteEvent rhs) {
        if(rhs.type == type) {
            drawables.addAll(rhs.drawables);
            for (Drawable drawableOuter:rhs.drawables) {
                boolean insert = true;
                for (Drawable drawableInner:drawables) {
                    if(drawableOuter == drawableInner) {
                        insert = false;
                        break;
                    }
                }
                if(insert) drawables.add(drawableOuter);
            }
        }
    }

    public int[] getIDs() {
        int[] ids = new int[drawables.size()];
        int i = 0;
        for (Drawable drawable:drawables) {
            ids[i++] = drawable.getID();
        }
        Arrays.sort(ids);
        return ids;
    }
}
