package GeomatPlot.Event;

import GeomatPlot.AbstractWindow;
import GeomatPlot.Draw.Drawable;
import GeomatPlot.Draw.DrawableType;

import java.awt.AWTEvent;
import java.util.Arrays;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

public class DeleteEvent extends AWTEvent {
    public static final int DELETE_EVENT = RESERVED_ID_MAX + 12;
    public List<Drawable> drawables;
    public DrawableType type;

    public DeleteEvent(AbstractWindow w, Drawable[] drawablesInit) {
        super(w, DELETE_EVENT);
        drawables = new LinkedList<>();
        Collections.addAll(drawables, drawablesInit);
        type = drawablesInit[0].getType();
    }

    public DeleteEvent(AbstractWindow w, Drawable drawable) {
        this(w, new Drawable[]{drawable});
    }

    public void merge(DeleteEvent rhs) {
        if(rhs.type == type) {
            drawables.addAll(rhs.drawables);
        }
    }
}
