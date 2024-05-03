package GeomatPlot.Event;

import GeomatPlot.AbstractWindow;
import GeomatPlot.Draw.Drawable;

import java.awt.AWTEvent;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

public class CreateEvent extends AWTEvent {
    public static final int CREATE_EVENT = RESERVED_ID_MAX + 10;
    public List<Drawable> drawables;
    public Drawable.DrawableType type;

    public CreateEvent(AbstractWindow w, Drawable drawable) {
        super(w, CREATE_EVENT);
        drawables = new LinkedList<>();
        drawables.add(drawable);
        type = drawable.getType();
    }

    public CreateEvent(AbstractWindow w, Drawable[] drawablesInit) {
        super(w, CREATE_EVENT);
        drawables = new LinkedList<>();
        Collections.addAll(drawables, drawablesInit);
        type = drawablesInit[0].getType();
    }

    public void merge(CreateEvent rhs) {
        if(rhs.type == type) {
            drawables.addAll(rhs.drawables);
        }
    }
}
