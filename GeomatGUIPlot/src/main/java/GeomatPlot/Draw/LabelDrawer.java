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
    public LabelDrawer(GL4 gl, FontMap fontMap) {
        this.fontMap = fontMap;
        syncedDrawables = new ArrayList<>();
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
        event.drawables.forEach(d -> ((gLabel)d).fontMap = fontMap);
    }

    @Override
    public void drawInner(GL4 gl) {
        if(fontMap.newFont) {
            drawCount = 0;
            labelBuffer.clear();
            fontMap.newFont = false;
            fontMap.generateBitmap(gl);
            syncInner(gl, 0);
        }

        gl.glBindBufferBase(GL_SHADER_STORAGE_BUFFER,1,labelBuffer.buffer);
        shader.use(gl);
        gl.glDrawArrays(GL_TRIANGLES,0,drawCount);
    }

    @Override
    public void syncInner(GL4 gl, int start) {
        if(fontMap.newFont) return;

        List<Drawable> newElements = syncedDrawables.subList(start, syncedDrawables.size());
        for (Drawable drawable:newElements)
            drawCount += ((gLabel)drawable).letterCount() * 6;

        labelBuffer.add(gl, toPackableFloat(newElements));
    }

    @Override
    public void syncInner(GL4 gl, int first, int last) {
        labelBuffer.update(gl, toPackableFloat(syncedDrawables), first, last);
    }

    @Override
    public Drawable.DrawableType requiredType() {
        return Drawable.DrawableType.Label;
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void deleteInner(GL4 gl, int[] IDs) {
        int[] offsets = new int[IDs.length];
        int[] ranges = new int[IDs.length];

        int currentOffset = 0;
        int index = 0;
        for (gLabel label:(List<gLabel>)(Object)syncedDrawables) {
            int bytes = label.bytes();
            if(index < IDs.length && IDs[index] == label.getID()) {
                drawCount -= label.letterCount() * 6;
                offsets[index] = currentOffset;
                ranges[index] = bytes;
            }
            currentOffset += bytes;
        }

        labelBuffer.deleteRange(gl, offsets, ranges);
    }
}
