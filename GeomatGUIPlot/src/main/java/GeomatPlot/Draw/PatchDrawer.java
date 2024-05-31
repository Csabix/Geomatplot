package GeomatPlot.Draw;

import GeomatPlot.*;
import GeomatPlot.Mem.ManagedFloatBuffer;
import GeomatPlot.Mem.ManagedIntBuffer;
import com.jogamp.opengl.GL4;

import java.util.ArrayList;
import java.util.List;

import static com.jogamp.opengl.GL.*;
import static com.jogamp.opengl.GL.GL_UNSIGNED_INT;
import static com.jogamp.opengl.GL3ES3.GL_DRAW_INDIRECT_BUFFER;

public class PatchDrawer extends Drawer{
    private static final int INITIAL_CAPACITY = 300 * gPatch.BYTE;
    private final PatchLineDrawer lineDrawer;
    protected final ProgramObject shader;
    protected final int vao;
    protected final ManagedFloatBuffer polygonFaceBuffer;
    protected final ManagedIntBuffer indexBuffer;
    protected final ManagedIntBuffer ibo;
    private int currentIndexCount;
    private int currentVertexCount;

    public PatchDrawer(GL4 gl, PatchLineDrawer patchLineDrawer) {
        currentIndexCount = 0;
        lineDrawer = patchLineDrawer;
        currentVertexCount = 0;

        syncedDrawables = new ArrayList<>();

        shader = new ProgramObjectBuilder(gl)
                .vertex("/Polygon.vert")
                .fragment("/Polygon.frag")
                .build();
        gl.glUniformBlockBinding(shader.ID,0,0);

        polygonFaceBuffer = new ManagedFloatBuffer(gl, INITIAL_CAPACITY);
        indexBuffer = new ManagedIntBuffer(gl);
        ibo = new ManagedIntBuffer(gl);

        vao = GLObject.createVertexArrays(gl, 1)[0];

        gl.glEnableVertexArrayAttrib(vao,0);
        gl.glVertexArrayAttribBinding(vao,0,0);
        gl.glVertexArrayAttribFormat(vao, 0, 4, gl.GL_FLOAT, false, 0);

        gl.glEnableVertexArrayAttrib(vao,1);
        gl.glVertexArrayAttribBinding(vao,1,0);
        gl.glVertexArrayAttribFormat(vao, 1, 2, gl.GL_FLOAT, false, 4 * Float.BYTES);

        gl.glVertexArrayVertexBuffer(vao, 0, polygonFaceBuffer.buffer, 0, gPatch.BYTE);
        gl.glVertexArrayElementBuffer(vao, indexBuffer.buffer);
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void syncInner(GL4 gl, int first, int last) {
        // Update Border
        int lFirst = Integer.MAX_VALUE;
        int lLast = Integer.MIN_VALUE;
        for (int i = first; i < last; ++i) {
            gPatch current = (gPatch)syncedDrawables.get(i);
            gPatchLine line = current.line;
            current.updateLine();
            int id = line.getID();
            if(id < lFirst)lFirst = id;
            if(id > lLast)lLast = id;
        }
        lineDrawer.syncInner(gl, lFirst, lLast + 1);
        // Update Face
        polygonFaceBuffer.update(gl,toPackableFloat(syncedDrawables),first,last);
        // Update Indices
        int indexCount = 0;
        for (gPatch drawable:(List<gPatch>)(Object)syncedDrawables) {
            indexCount += drawable.indices.length * 3;
        }

        currentIndexCount = 0;
        currentVertexCount = 0;
        int[] indices = getIndices(indexCount, syncedDrawables);

        indexBuffer.clear();
        indexBuffer.add(gl, indices);

    }

    @SuppressWarnings("unchecked")
    @Override
    protected void syncInner(GL4 gl, int start) {
        List<Drawable> sublist = syncedDrawables.subList(start,syncedDrawables.size());
        List<Drawable> lines = new ArrayList<>(sublist.size());

        int indexCount = 0;
        for (gPatch patch:(List<gPatch>)(Object)sublist) {
            lines.add(patch.getLine());
            indexCount += patch.indices.length;
        }
        indexCount *= 3;

        ArrayList<DrawElementsIndirectCommand> indirectCommands = new ArrayList<>(sublist.size());
        int[] indices = getIndices(indexCount, sublist, indirectCommands);

        // Border data
        lineDrawer.add(lines);
        lineDrawer.sync(gl);
        // Face data
        polygonFaceBuffer.add(gl, toPackableFloat(sublist));
        indexBuffer.add(gl, indices);
        // Draw command
        ibo.add(gl, toPackableInt(indirectCommands));
    }

    @Override
    protected void drawInner(GL4 gl) {
        gl.glBindVertexArray(vao);
        gl.glBindBuffer(GL_DRAW_INDIRECT_BUFFER, ibo.buffer);
        gl.glUseProgram(shader.ID);
        gl.glUniform1i(shader.getUniformLocation(gl, "drawerID"), getDrawID());
        gl.glMultiDrawElementsIndirect(GL_TRIANGLES, GL_UNSIGNED_INT, null, syncedDrawables.size(), 0);
    }

    @Override
    public void clean(GL4 gl) {
        polygonFaceBuffer.clean(gl);
        indexBuffer.clean(gl);
        ibo.clean(gl);
        shader.delete(gl);
        GLObject.deleteVertexArrays(gl, new int[]{vao});
        syncedDrawables.clear();
    }

    @Override
    public DrawableType requiredType() {
        return DrawableType.Patch;
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void deleteInner(GL4 gl, int[] IDs) {
        // Remove borders
        List<Drawable> lines = new ArrayList<>(IDs.length);
        for (int id : IDs) {
            lines.add(((gPatch) syncedDrawables.get(id)).line);
        }
        lineDrawer.remove(lines);
        lineDrawer.sync(gl);
        // Remove Polygons
        List<Drawable> keeps = new ArrayList<>(syncedDrawables.size() - IDs.length);

        int currentPolyOffset = 0;
        int[] polyOffsets = new int[IDs.length];
        int[] polyRanges = new int[IDs.length];

        int indexCount = 0;

        int currentID = 0;
        for (gPatch drawable:(List<gPatch>)(Object)syncedDrawables) {
            if(currentID < IDs.length && drawable.getID() == IDs[currentID]) {
                polyOffsets[currentID] = currentPolyOffset;
                polyRanges[currentID] = drawable.bytes();
                ++currentID;
            } else {
                keeps.add(drawable);
                indexCount += drawable.indices.length * 3;
            }
            currentPolyOffset = drawable.bytes();
        }

        polygonFaceBuffer.deleteRange(gl, polyOffsets, polyRanges);

        currentIndexCount = 0;
        currentVertexCount = 0;
        ArrayList<DrawElementsIndirectCommand> indirectCommands = new ArrayList<>(keeps.size());
        int[] indices = getIndices(indexCount, keeps, indirectCommands);

        indexBuffer.clear();
        if(indices.length != 0)indexBuffer.add(gl, indices);

        ibo.clear();
        ibo.add(gl, toPackableInt(indirectCommands));
    }

    @SuppressWarnings("unchecked")
    private int[] getIndices(int indexCount, List<Drawable> sublist) {
        int[] indices = new int[indexCount];
        int position = 0;
        for (gPatch patch:(List<gPatch>)(Object)sublist) {
            for (int i = 0; i < patch.indices.length; ++i) {
                indices[position++] = patch.indices[i][0] + currentVertexCount;
                indices[position++] = patch.indices[i][1] + currentVertexCount;
                indices[position++] = patch.indices[i][2] + currentVertexCount;
            }
            currentVertexCount += patch.x.length;
            currentIndexCount += patch.indices.length * 3;
        }
        return indices;
    }

    @SuppressWarnings("unchecked")
    private int[] getIndices(int indexCount, List<Drawable> sublist, List<DrawElementsIndirectCommand> indirectCommands) {
        int[] indices = new int[indexCount];
        int position = 0;
        for (gPatch patch:(List<gPatch>)(Object)sublist) {
            indirectCommands.add(new DrawElementsIndirectCommand(patch.indices.length * 3, currentIndexCount));
            for (int i = 0; i < patch.indices.length; ++i) {
                indices[position++] = patch.indices[i][0] + currentVertexCount;
                indices[position++] = patch.indices[i][1] + currentVertexCount;
                indices[position++] = patch.indices[i][2] + currentVertexCount;
            }
            currentVertexCount += patch.x.length;
            currentIndexCount += patch.indices.length * 3;
        }
        return indices;
    }
}
