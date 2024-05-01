package GeomatPlot.Draw;

import GeomatPlot.*;
import GeomatPlot.Mem.ManagedFloatBuffer;
import GeomatPlot.Mem.ManagedIntBuffer;
import GeomatPlot.Mem.PackableFloat;
import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.LinkedList;
import java.util.List;

import static com.jogamp.opengl.GL.*;
import static com.jogamp.opengl.GL3ES3.GL_DRAW_INDIRECT_BUFFER;
import static com.jogamp.opengl.GL3ES3.GL_SHADER_STORAGE_BUFFER;

// https://stackoverflow.com/questions/60440682/drawing-a-line-in-modern-opengl
// https://www.codeproject.com/articles/199525/drawing-nearly-perfect-2d-line-segments-in-opengl
// https://www.codeproject.com/Articles/226569/Drawing-polylines-by-tessellation

public class LineDrawer<T extends  gLine> extends Drawer{
    private static final Integer INITIAL_CAPACITY = 1 * gLine.VERTEX_BYTE;
    ProgramObject shader;
    private final ManagedFloatBuffer lineBuffer;
    private final ManagedIntBuffer indirectDrawArraysCommandBuffer;
    private int nextIndex;
    public LineDrawer(GL4 gl) {
        drawableList = new ArrayList<>();

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Line.vert")
                .fragment("/Line.frag")
                .build();
        gl.glUniformBlockBinding(shader.ID,0,0);


        nextIndex = 0;
        lineBuffer = new ManagedFloatBuffer(gl, INITIAL_CAPACITY);
        indirectDrawArraysCommandBuffer = new ManagedIntBuffer(gl, 100 * DrawArraysIndirectCommand.BYTES);
    }
    @Override
    protected void syncInner(GL4 gl, Integer first, Integer last) {
        lineBuffer.update(gl,toPackableFloat(drawableList),first,last);
    }

    @Override
    protected void syncInner(GL4 gl) {
        List<Tuple<Integer, Integer>> ranges = new ArrayList<>(drawableList.size() - syncedDrawable);
        for (int i = syncedDrawable; i < drawableList.size(); i++) {
            int indSize = ((((T)drawableList.get(i)).x.length - 1) * 6);
            ranges.add(new Tuple<>(nextIndex, indSize));
            nextIndex += indSize + 18;
        }

        List<DrawArraysIndirectCommand> commands = new ArrayList<>(drawableList.size() - syncedDrawable);
        for (Tuple<Integer, Integer> range: ranges) {
            commands.add(new DrawArraysIndirectCommand(range.second,range.first));
        }

        indirectDrawArraysCommandBuffer.add(gl, toPackableInt(commands));
        lineBuffer.add(gl, toPackableFloat(drawableList.subList(syncedDrawable, drawableList.size())));
    }

    @Override
    protected void drawInner(GL4 gl) {
        gl.glBindBufferBase(GL_SHADER_STORAGE_BUFFER,1,lineBuffer.buffer);
        shader.use(gl);
        gl.glUniform1i(shader.getUniformLocation(gl, "drawerID"), getDrawID());
        gl.glBindBuffer(GL_DRAW_INDIRECT_BUFFER, indirectDrawArraysCommandBuffer.buffer);
        gl.glMultiDrawArraysIndirect(GL_TRIANGLES, 0, syncedDrawable, 0);
    }

    @Override
    protected void deleteInner(GL4 gl, int[] IDs) throws Exception {
        int[] offsets = new int[IDs.length];
        int[] lineRanges = new int[IDs.length];
        int resultIndex = 0;
        int currentOffset = 0;
        int currentID = 0;

        for (Drawable drawable:drawableList) {
            if(resultIndex == IDs.length || currentID == IDs.length)break;
            if(drawable.getID() == IDs[currentID]) {
                offsets[resultIndex] = currentOffset;
                lineRanges[resultIndex] = drawable.bytes();
                ++resultIndex;
                ++currentID;
            }
            currentOffset += drawable.bytes();
        }

        lineBuffer.deleteRange(gl, offsets, lineRanges);

        for (int i = 0; i < IDs.length; i++) {
            offsets[i] = DrawArraysIndirectCommand.BYTES * IDs[i];
        }

        indirectDrawArraysCommandBuffer.clear();

        currentID = 0;
        nextIndex = 0;
        List<Tuple<Integer, Integer>> ranges = new ArrayList<>(drawableList.size() - IDs.length);
        for (int i = 0; i < drawableList.size(); i++) {
            T current = (T)drawableList.get(i);
            if(currentID < IDs.length && current.getID() == IDs[currentID]) {
                ++currentID;
                continue;
            }
            int indSize = (current.x.length - 1) * 6;
            ranges.add(new Tuple<>(nextIndex, indSize));
            nextIndex += indSize + 18;
        }

        List<DrawArraysIndirectCommand> commands = new ArrayList<>(drawableList.size() - IDs.length);
        for (Tuple<Integer, Integer> range: ranges) {
            commands.add(new DrawArraysIndirectCommand(range.second,range.first));
        }

        indirectDrawArraysCommandBuffer.add(gl, toPackableInt(commands));

    }

    @Override
    public Drawable.DrawableType requiredType() {
        return Drawable.DrawableType.Line;
    }
}
