package GeomatPlot.Draw;

import GeomatPlot.Draw.Drawable;

public class ObjectClicked {
    public final Drawable.DrawableType type;
    public Drawable data;
    public ObjectClicked(Drawable.DrawableType type, Drawable data) {
        this.type = type;
        this.data = data;
    }
}
