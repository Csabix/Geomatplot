package GeomatPlot.Draw;

import GeomatPlot.*;
import com.jogamp.opengl.GL;
import com.jogamp.opengl.GL4;

import java.util.ArrayList;
import java.util.List;

import static com.jogamp.opengl.GL.*;

public class FunctionDrawer extends Drawer{
    public static enum Resolution{DOUBLE, MATCHING, HALF, QUARTER;};

    Plot window;
    ProgramObject program;
    int[] fbos;
    int[] textures;

    int[] widths;
    int[] heights;

    public FunctionDrawer(GL4 gl, Plot window) {
        syncedDrawables = new ArrayList<>();
        this.window = window;
        fbos = null;
        textures = null;

        program = new ProgramObjectBuilder(gl)
                        .vertex("/Function.vert")
                        .fragment("/Function.frag")
                        .build();

        createFBOs(gl);
    }

    private void createFBO(GL4 gl, int i, int w, int h) {
        int current = textures[i];

        gl.glTextureParameteri(current, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        gl.glTextureParameteri(current, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        gl.glTextureParameteri(current, GL_TEXTURE_WRAP_S,     GL_CLAMP_TO_EDGE);
        gl.glTextureParameteri(current, GL_TEXTURE_WRAP_T,     GL_CLAMP_TO_EDGE);
        gl.glTextureStorage2D(current, 1, GL_RGBA8, w, h);

        gl.glNamedFramebufferTexture(fbos[i],GL_COLOR_ATTACHMENT0,current,0);
    }

    public void createFBOs(GL4 gl) {
        int w = window.width;
        int h = window.height;

        if(fbos != null) {
            GLObject.deleteTextures(gl, textures);
            GLObject.deleteFrameBuffers(gl, fbos);
        }
        fbos = GLObject.createFrameBuffers(gl, 4);
        textures = GLObject.createTextures(gl, GL_TEXTURE_2D, 4);

        createFBO(gl, 0, w * 2, h * 2);
        createFBO(gl, 1, w, h);
        createFBO(gl, 2, w / 2, h / 2);
        createFBO(gl, 3, w / 4, h / 4);

        widths = new int[]{w*2,w,w/2,w/4};
        heights = new int[]{h*2,h,h/2,h/4};
    }

    @Override
    public void clean(GL4 gl) {
        if(fbos != null) {
            GLObject.deleteTextures(gl, textures);
            GLObject.deleteFrameBuffers(gl, fbos);
        }
        for (Drawable drawable:syncedDrawables) {
            ((gFunction)drawable).clean(gl);
        }
        program.delete(gl);
        syncedDrawables.clear();
    }

    @Override
    protected void syncInner(GL4 gl, int first, int last) {
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void syncInner(GL4 gl, int start) {
        List<gFunction> sublist = (List<gFunction>)(Object)syncedDrawables.subList(start,syncedDrawables.size());

        sublist.forEach(gFunction -> {
            gFunction.program = new ProgramObjectBuilder(gl)
                                .vertex("/Fullscreen.vert")
                                .fragmentUserDefined(gFunction.location)
                                .build();
        });
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void drawInner(GL4 gl) {
        int target = window.getFBO();

        List<gFunction> gFunctions = (List<gFunction>)(Object)syncedDrawables;
        for (gFunction gFunction:gFunctions) {
            // Draw to the texture with the right size
            int ordinal = gFunction.resolution.ordinal();
            int fbo = fbos[ordinal];
            gl.glBindFramebuffer(GL_FRAMEBUFFER,fbo);
            gl.glViewport(0,0 , widths[ordinal], heights[ordinal]);
            gl.glClear(GL_COLOR_BUFFER_BIT);

            gFunction.program.use(gl);
            gl.glDrawArrays(GL_TRIANGLES, 0, 6);
            // Draw to the 'screen'
            gl.glViewport(0,0,window.width,window.height);

            gl.glBindFramebuffer(GL_FRAMEBUFFER,target);
            program.use(gl);
            gl.glBindTextureUnit(0, textures[ordinal]);
            gl.glDrawArrays(GL_TRIANGLES, 0, 6);
        }
    }

    @Override
    public DrawableType requiredType() {
        return DrawableType.Function;
    }

    @Override
    protected void deleteInner(GL4 gl, int[] IDs) {
        for (int id : IDs) {
            ((gFunction) syncedDrawables.get(id)).clean(gl);
        }
    }
}
