package GeomatPlot.Draw;

import GeomatPlot.Event.CreateEvent;
import GeomatPlot.Event.DeleteEvent;
import GeomatPlot.Event.UpdateEvent;
import GeomatPlot.Mem.PackableFloat;
import GeomatPlot.Mem.PackableInt;
import com.jogamp.opengl.GL4;

import java.util.*;


public abstract class Drawer {
    public static final int ID_BIT_COUNT = 8;
    private final int drawID = requiredType().ordinal() << (Integer.BYTES * 8 - ID_BIT_COUNT);
    protected List<Drawable> syncedDrawables;
    private List<Drawable> drawablesToAdd = null;
    private List<Drawable> drawablesToRemove = null;
    private List<Drawable> drawablesToUpdate = null;

    protected abstract void syncInner(GL4 gl, int first, int last); // Update elements [first, last[

    protected abstract void syncInner(GL4 gl, int start); // Add new elements

    protected abstract void drawInner(GL4 gl);

    protected void deleteInner(GL4 gl, int[] IDs) {
        throw new RuntimeException("Deletion not supported");
    };

    public abstract DrawableType requiredType();

    public abstract void clean(GL4 gl);

    protected int getDrawID() {
        return drawID;
    }

    public void sync(GL4 gl) {
        if(drawablesToRemove != null && drawablesToRemove.size() != 0) deleteDrawables(gl);

        if(drawablesToAdd != null && drawablesToAdd.size() != 0)addDrawables(gl);

        if(drawablesToUpdate != null && drawablesToUpdate.size() != 0)updateDrawables(gl);
    }

    public void update(UpdateEvent event) {
        if(event.type != requiredType()) return;
        update(event.drawables);
    }
    protected void update(List<Drawable> drawables) {
        drawablesToUpdate = drawables;
    }

    public void add(CreateEvent event) {
        if(event.type != requiredType()) return;
        add(event.drawables);
    }
    protected void add(List<Drawable> drawables) {
        drawablesToAdd = drawables;
    }

    public void remove(DeleteEvent event) {
        if(event.type != requiredType()) return;
        remove(event.drawables);
    }
    protected void remove(List<Drawable> drawables) {
        drawablesToRemove = drawables;
    }

    public void draw(GL4 gl) {
        if (syncedDrawables.size() > 0) {
            drawInner(gl);
        }
    }

    private void deleteDrawables(GL4 gl) {
        List<Drawable> needToDelete = new LinkedList<>();
        List<Drawable> noNeedToDelete = new LinkedList<>();
        // Filter out elements we don't have in the buffer
        for (Drawable drawable:drawablesToRemove) {
            if(drawable.getID() != -1) {
                needToDelete.add(drawable);
            } else {
                noNeedToDelete.add(drawable);
            }
        }
        // We don't need to add them, or update them
        if(drawablesToAdd != null)drawablesToAdd.removeAll(noNeedToDelete);
        if(drawablesToUpdate != null) {
            drawablesToUpdate.removeAll(noNeedToDelete);
            drawablesToUpdate.removeAll(needToDelete);
        }

        if(needToDelete.size() != 0)deleteInner(gl, getIDs(needToDelete));
        for (Drawable drawable:needToDelete) {
            drawable.setID(-1);
        }

        // Remove deleted objects from syncedDrawables
        TreeSet<Drawable> treeSet = new TreeSet<>(syncedDrawables);
        needToDelete.forEach(treeSet::remove);
        syncedDrawables = new ArrayList<>(treeSet);
        // Reassign the IDs
        int nextID = 0;
        for (Drawable drawable:syncedDrawables) {
            drawable.setID(nextID++);
        }

        drawablesToRemove = null;
    }

    private void addDrawables(GL4 gl) {
        LinkedList<Integer> duplicateAdd = new LinkedList<>();

        int start = syncedDrawables.size();
        int nextID = start;
        int i = 0;
        for (Drawable drawable:drawablesToAdd) {
            if(drawable.getID() == -1) {
                drawable.setID(nextID++);
            } else {
                duplicateAdd.addFirst(i);
            }
            ++i;
        }

        for (int index:duplicateAdd) {
            drawablesToAdd.remove(index);
        }

        syncedDrawables.addAll(drawablesToAdd);
        syncInner(gl, start);
        // We just added them we don't need to update them
        if(drawablesToUpdate != null) drawablesToUpdate.removeAll(drawablesToAdd);
        drawablesToAdd = null;
    }

    private void updateDrawables(GL4 gl) {
        int min = Integer.MAX_VALUE;
        int max = Integer.MIN_VALUE;
        for (Drawable drawable:drawablesToUpdate) {
            int id = drawable.getID();
            if (id != -1) {
                if (id > max) max = id;
                if (id < min) min = id;
            }
        }
        if(min != Integer.MAX_VALUE && max != Integer.MIN_VALUE)syncInner(gl, min, max + 1);

        drawablesToUpdate = null;
    }

    private int[] getIDs(List<Drawable> drawables) {
        // Return the indexes of the elements sorted, no duplicate
        SortedSet<Integer> IDSet = new TreeSet<>();
        for (Drawable drawable:drawables) {
            IDSet.add(drawable.getID());
        }
        int[] IDs = new int[IDSet.size()];

        int position = 0;
        for (Integer id:IDSet) {
            IDs[position++] = id;
        }

        return IDs;
    }

    public Drawable getDrawable(int id) {
        return syncedDrawables.get(id);
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