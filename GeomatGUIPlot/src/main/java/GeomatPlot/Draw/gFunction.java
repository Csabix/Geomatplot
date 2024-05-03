package GeomatPlot.Draw;

import GeomatPlot.ProgramObject;
import com.jogamp.opengl.GL4;

public class gFunction extends Drawable{
    public String location;
    public FunctionDrawer.Resolution resolution;
    protected ProgramObject program;
    protected int fbo;

    public gFunction(String fileLocation, FunctionDrawer.Resolution resolution) {
        super(false);
        program = null;
        fbo = 0;
        location = fileLocation;
        this.resolution = resolution;
    }

    public gFunction(){super(false);};

    public void clean(GL4 gl) {
        if (program != null) {
            program.delete(gl);
        }
    };

    @Override
    public float[] pack() {
        return null;
    }

    @Override
    public int elementCount() {
        return 0;
    }

    @Override
    public int bytes() {
        return 0;
    }

    @Override
    public DrawableType getType() {
        return DrawableType.Function;
    }
}
