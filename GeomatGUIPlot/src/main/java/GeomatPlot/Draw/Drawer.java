package GeomatPlot.Draw;

import GeomatPlot.Event.CreateEvent;
import GeomatPlot.Event.DeleteEvent;
import GeomatPlot.Event.UpdateEvent;
import GeomatPlot.Mem.PackableFloat;
import GeomatPlot.Mem.PackableInt;
import GeomatPlot.Tuple;
import com.jogamp.opengl.GL4;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

public abstract class Drawer {
    public static final int ID_BIT_COUNT = 8;
    private final int drawID = requiredType().ordinal() << (Integer.BYTES * 8 - ID_BIT_COUNT);
    protected List<Drawable> drawableList;
    private DeleteEvent toBeDeleted = null;
    protected int syncedDrawable = 0;
    protected int nextID = 0;
    protected abstract void syncInner(GL4 gl, Integer first, Integer last); // [first, last]
    protected abstract void syncInner(GL4 gl);
    protected abstract void drawInner(GL4 gl);
    protected void deleteInner(GL4 gl, int[] IDs) throws Exception {
        throw new Exception("Deletion not supported");
    };

    protected void directDeleteCall(GL4 gl, int[] IDs) {
        if (syncedDrawable < drawableList.size()) {
            syncInner(gl);
            syncedDrawable = drawableList.size();
        }
        try {
            deleteInner(gl, IDs);
            List<Drawable> drawables = new ArrayList<>(IDs.length);
            for (int id : IDs) {
                drawables.add(drawableList.get(id));
            }

            drawableList.removeAll(drawables);

            nextID = 0;
            for (Drawable drawable:drawableList) {
                drawable.setID(nextID++);
            }
        } catch (Exception e) {
            System.out.println(e.getMessage());
            e.printStackTrace();
        }
        syncedDrawable = drawableList.size();
    }

    public abstract Drawable.DrawableType requiredType();
    protected int getDrawID() {
        return drawID;
    }
    public void sync(GL4 gl) {
        if (syncedDrawable < drawableList.size()) {
            syncInner(gl);
            syncedDrawable = drawableList.size();
        }
        if (toBeDeleted != null) {
            int[] IDs = toBeDeleted.getIDs();
            try {
                deleteInner(gl, IDs);
                drawableList.removeAll(toBeDeleted.drawables);
                nextID = 0;
                for (Drawable drawable:drawableList) {
                    drawable.setID(nextID++);
                }
            } catch (Exception e) {
                System.out.println(e.getMessage());
                e.printStackTrace();
            }
            toBeDeleted = null;
            syncedDrawable = drawableList.size();
        }
    }
    public void sync(GL4 gl, UpdateEvent event) {
        if(event.type != requiredType()) return;
        Tuple<Integer,Integer> range = event.range();
        syncInner(gl, range.first, range.second);
    }
    public void add(CreateEvent event) {
        if(event.type != requiredType()) return;
        add(event.drawables);
    }
    public void add(List<Drawable> drawables) {
        for (Drawable newDrawable : drawables) {
            newDrawable.setID(nextID++);
        }
        this.drawableList.addAll(drawables);
    }
    public void remove(DeleteEvent event) {
        if(event.type != requiredType()) return;
        toBeDeleted = event;
    }
    public void draw(GL4 gl) {
        if (syncedDrawable > 0) {
            drawInner(gl);
        }
    }

    public Drawable getDrawable(int id) {
        return drawableList.get(id);
    }

    @SuppressWarnings("unchecked")
    protected List<PackableFloat> toPackableFloat(Object drawables){
        return (List<PackableFloat>)drawables;
    }
    @SuppressWarnings("unchecked")
    protected List<PackableInt> toPackableInt(Object drawables){
        return (List<PackableInt>)drawables;
    }
}
