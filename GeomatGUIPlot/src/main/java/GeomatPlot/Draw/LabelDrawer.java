package GeomatPlot.Draw;

import GeomatPlot.Event.CreateEvent;
import GeomatPlot.Font.FontMap;
import GeomatPlot.Mem.ManagedFloatBuffer;
import GeomatPlot.ProgramObject;
import GeomatPlot.ProgramObjectBuilder;
import com.jogamp.opengl.GL4;

import java.util.ArrayList;
import java.util.List;

import static com.jogamp.opengl.GL.*;
import static com.jogamp.opengl.GL3ES3.GL_SHADER_STORAGE_BUFFER;

public class LabelDrawer extends Drawer {
    private static final int INITIAL_CAPACITY = 100 * gLabel.BYTES;
    private final FontMap fontMap;
    private final ProgramObject shader;
    private final ManagedFloatBuffer labelBuffer;
    private int drawCount;
    public LabelDrawer(GL4 gl) {
        fontMap = new FontMap(gl);
        drawableList = new ArrayList<>();
        drawCount = 0;

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Letter.vert")
                .fragment("/Letter.frag")
                .build();
        gl.glUniformBlockBinding(shader.ID,0,0);

        labelBuffer = new ManagedFloatBuffer(gl, INITIAL_CAPACITY);
    }
    @Override
    public void add(CreateEvent event) {
        super.add(event);
        if(event.type == requiredType())event.drawables.forEach(d -> ((gLabel)d).fontMap = fontMap);
    }
    @Override
    public void drawInner(GL4 gl) {
        gl.glBindBufferBase(GL_SHADER_STORAGE_BUFFER,1,labelBuffer.buffer);
        shader.use(gl);
        gl.glDrawArrays(GL_TRIANGLES,0,drawCount);
    }
    @Override
    public void syncInner(GL4 gl) {
        for(int i = syncedDrawable; i < drawableList.size(); ++i) drawCount += ((gLabel)drawableList.get(i)).letterCount() * 6;

        labelBuffer.add(gl, toPackableFloat(drawableList.subList(syncedDrawable,drawableList.size())));
    }

    @Override
    public void syncInner(GL4 gl, Integer first, Integer last) {
        labelBuffer.update(gl, toPackableFloat(drawableList), first, last);
    }

    @Override
    public Drawable.DrawableType requiredType() {
        return Drawable.DrawableType.Label;
    }
}
