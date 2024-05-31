package GeomatPlot.Font;


class CInfo {
    public final int sourceX,sourceY;
    public final int width,height;
    public float x0,x1; // Top left  corner
    public float y0,y1; // Bottom right corner
    public CInfo(int sourceX, int sourceY, int width, int height) {
        this.sourceX = sourceX;
        this.sourceY = sourceY;
        this.width = width;
        this.height = height;
    }
    public void calculateTextureCoordinates(int fontMapWidth, int fontMapHeight) {
        x0 = (float)sourceX / (float)fontMapWidth;
        x1 = (float)(sourceX + width) / (float)fontMapWidth;
        y0 = (float)sourceY / (float)fontMapHeight;
        y1 = (float)(sourceY + height) / (float)fontMapHeight;
    }
}
