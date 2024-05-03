package GeomatPlot.Draw;

import GeomatPlot.Plot;

public class gPolygonPoint extends gPoint{
    public gPolygon polygon;
    private int polygonID;
    public gPolygonPoint(gPolygon polygon, float x, float y, float[] primaryColor, float width, boolean movable, int ID) {
        super(x, y, primaryColor, width, 0, movable);
        this.polygon = polygon;
        polygonID = ID;
    }

    @Override
    public DrawableType getType() {
        return DrawableType.PolygonPoint;
    }

    @Override
    public void move(Plot plot, float dX, float dY) {
        this.x += dX;
        this.y += dY;
        plot.updateDrawable(this);

        polygon.x[polygonID] += dX;
        polygon.y[polygonID] += dY;
        polygon.line.x[polygonID] += dX;
        polygon.line.y[polygonID] += dY;

        plot.updateDrawable(polygon);
        polygon.notifyDrawable();
    }
}
