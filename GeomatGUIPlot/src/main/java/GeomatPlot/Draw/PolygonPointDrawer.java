package GeomatPlot.Draw;

import com.jogamp.opengl.GL4;

public class PolygonPointDrawer extends PointDrawer<gPolygonPoint>{
    public PolygonPointDrawer(GL4 gl) {
        super(gl);
    }

    @Override
    public Drawable.DrawableType requiredType() {
        return Drawable.DrawableType.PolygonPoint;
    }

    @Override
    protected void deleteInner(GL4 gl, int[] IDs) {
        super.deleteInner(gl, IDs);
    }
}
