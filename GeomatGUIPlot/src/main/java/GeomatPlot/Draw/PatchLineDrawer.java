package GeomatPlot.Draw;

import com.jogamp.opengl.GL4;

public class PatchLineDrawer extends LineDrawer<gPatchLine>{
    public PatchLineDrawer(GL4 gl) {
        super(gl);
    }

    @Override
    public DrawableType requiredType() {
        return DrawableType.PatchLine;
    }

    @Override
    public Drawable getDrawable(int id) {
        return ((gPatchLine)syncedDrawables.get(id)).parent;
    }
}
