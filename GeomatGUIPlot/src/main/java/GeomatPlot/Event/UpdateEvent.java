package GeomatPlot.Event;

import GeomatPlot.AbstractWindow;
import GeomatPlot.Draw.Drawable;
import GeomatPlot.Draw.DrawableType;

import java.awt.AWTEvent;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

public class UpdateEvent extends AWTEvent {
    public static final int UPDATE_EVENT = RESERVED_ID_MAX + 11;
    public List<Drawable> drawables;
    public DrawableType type;

    public UpdateEvent(AbstractWindow w, Drawable[] drawablesInit) {
        super(w, UPDATE_EVENT);
        drawables = new LinkedList<>();
        Collections.addAll(drawables, drawablesInit);
        type = drawablesInit[0].getType();
    }

    public UpdateEvent(AbstractWindow w, Drawable drawable) {
        this(w, new Drawable[]{drawable});
    }

    public void merge(UpdateEvent rhs) {
        if(rhs.type == type) {
            drawables.addAll(rhs.drawables);
        }
    }

}
