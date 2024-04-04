package GeomatPlot.Draw;

import com.jogamp.opengl.GL4;

import java.util.List;
import java.util.stream.Collectors;

public abstract class Drawer {
    protected List<Drawable> drawableList;
    protected int syncedDrawable = 0;
    protected int nextID = 0;
    protected abstract void syncInner(GL4 gl, List<Integer> IDs, Integer first, Integer last);
    protected abstract void syncInner(GL4 gl);
    protected abstract void drawInner(GL4 gl);
    public void sync(GL4 gl) {
        if (syncedDrawable < drawableList.size()) {
            syncInner(gl);
            syncedDrawable = drawableList.size();
        }
    }
    public void sync(GL4 gl, List<Integer> IDs) {
        IDs = IDs.stream().distinct().collect(Collectors.toList());
        Integer min = Integer.MAX_VALUE;
        Integer max = Integer.MIN_VALUE;
        for (Integer ID:IDs) {
            if (ID > max) max = ID;
            if (ID < min) min = ID;
        }
        syncInner(gl, IDs, min, max);
    }
    public void add(List<Drawable> drawableList) {
        for (int i = 0; i < drawableList.size(); i++) {
            drawableList.get(i).setID(i + nextID);
        }
        this.drawableList.addAll(drawableList);
        nextID = this.drawableList.size();
    }
    public void draw(GL4 gl) {
        if (syncedDrawable > 0) {
            drawInner(gl);
        }
    }
}
