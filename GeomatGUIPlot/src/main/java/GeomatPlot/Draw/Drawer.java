package GeomatPlot.Draw;

import GeomatPlot.Event.CreateEvent;
import GeomatPlot.Event.UpdateEvent;
import com.jogamp.opengl.GL4;

import java.util.List;
import java.util.stream.Collectors;

public abstract class Drawer {
    public static final int ID_BIT_COUNT = 8;
    protected List<Drawable> drawableList;
    protected int syncedDrawable = 0;
    protected int nextID = 0;
    protected abstract void syncInner(GL4 gl, List<Integer> IDs, Integer first, Integer last); // [first, last]
    protected abstract void syncInner(GL4 gl);
    protected abstract void drawInner(GL4 gl);
    public abstract Drawable.DrawableType requiredType();
    protected int getDrawID() {
        return requiredType().ordinal() << (Integer.BYTES * 8 - ID_BIT_COUNT);
    }
    public void sync(GL4 gl) {
        if (syncedDrawable < drawableList.size()) {
            syncInner(gl);
            syncedDrawable = drawableList.size();
        }
    }
    public void sync(GL4 gl, UpdateEvent event) {
        if(event.type != requiredType()) return;
        List<Integer> IDs = event.IDs.stream().distinct().collect(Collectors.toList());
        Integer min = Integer.MAX_VALUE;
        Integer max = Integer.MIN_VALUE;
        for (Integer ID:IDs) {
            if (ID > max) max = ID;
            if (ID < min) min = ID;
        }
        syncInner(gl, IDs, min, max);
    }
    public void add(CreateEvent event) {
        if(event.type != requiredType()) return;
        for (Drawable newDrawable : event.drawables) {
            newDrawable.setID(nextID++);
        }
        this.drawableList.addAll(event.drawables);
    }
    public void draw(GL4 gl) {
        if (syncedDrawable > 0) {
            drawInner(gl);
        }
    }
}
