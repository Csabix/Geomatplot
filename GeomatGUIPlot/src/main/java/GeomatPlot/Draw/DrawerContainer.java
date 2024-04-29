package GeomatPlot.Draw;

import GeomatPlot.Event.CreateEvent;
import GeomatPlot.Event.DeleteEvent;
import GeomatPlot.Event.UpdateEvent;
import com.jogamp.opengl.GL4;

import java.util.Optional;

public class DrawerContainer {
    private static final Drawable.DrawableType[] values = Drawable.DrawableType.values(); // Caching
    private static final int bitmask = genBitmask();
    private final Drawer[] drawers;
    public DrawerContainer(GL4 gl) {
        final PatchLineDrawer patchLineDrawer = new PatchLineDrawer(gl);
        final PolygonPointDrawer polygonPointDrawer = new PolygonPointDrawer(gl);
        final Drawer[] initDrawers = {  new PointDrawer<gPoint>(gl), new LineDrawer<gLine>(gl), new LabelDrawer(gl),
                                        new PatchDrawer(gl,patchLineDrawer), patchLineDrawer, polygonPointDrawer,
                                        new PolygonDrawer(gl, patchLineDrawer, polygonPointDrawer)};
        drawers = new Drawer[values.length];
        for (Drawer drawer : initDrawers) {
            drawers[drawer.requiredType().ordinal()] = drawer;
        }
    }
    public void callAdd(CreateEvent event) {
        drawers[event.type.ordinal()].add(event);
    }
    public void callRemove(DeleteEvent event) {
        drawers[event.type.ordinal()].remove(event);
    }
    public void callSync(GL4 gl) {
        for (Drawer drawer : drawers) {
            if(drawer != null)drawer.sync(gl);
        }
    }
    public void callSync(GL4 gl, UpdateEvent event) {
        drawers[event.type.ordinal()].sync(gl, event);
    }
    public void callDraw(GL4 gl) {
        for (Drawer drawer : drawers) {
            if(drawer != null)drawer.draw(gl);
        }
    }
    public Optional<ObjectClicked> getClicked(int typeID) {
        if (typeID == -1) return Optional.empty();
        int ordinal  = typeID >>> Integer.BYTES * 8 - Drawer.ID_BIT_COUNT;
        int id = typeID & bitmask;

        Drawable drawable = drawers[ordinal].getDrawable(id);

        return Optional.of(new ObjectClicked(drawable.getType(), drawable));
    }
    private static int genBitmask() {
        char[] chars = new char[Integer.BYTES * 8];
        for (int i = 0; i < Drawer.ID_BIT_COUNT; i++) {
            chars[i] = '0';
        }
        for (int i = Drawer.ID_BIT_COUNT; i < chars.length; i++) {
            chars[i] = '1';
        }
        return Integer.parseUnsignedInt(new String(chars), 2);
    }
}
