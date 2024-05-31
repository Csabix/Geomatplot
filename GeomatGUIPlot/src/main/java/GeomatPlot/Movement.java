package GeomatPlot;

import GeomatPlot.Draw.Drawable;

public class Movement {
    private final Drawable drawable;
    private float startX, startY;

    public Movement(Drawable drawable, float startX, float startY) {
        this.drawable = drawable;
        this.startX = startX;
        this.startY = startY;
    }

    public void drag(Plot plot, float mouseX, float mouseY) {
        // Calculate how much was it moved since last frame
        float dX = mouseX - startX;
        float dY = mouseY - startY;
        startX = mouseX;
        startY = mouseY;
        // Update it
        drawable.move(plot, dX, dY);
    }
}
