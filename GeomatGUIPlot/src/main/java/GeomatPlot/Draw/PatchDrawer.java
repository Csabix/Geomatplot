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
    private static final int INITIAL_CAPACITY = 100 * gPatch.BYTE;
    private final PatchLineDrawer lineDrawer;
    private final ProgramObject shader;
    private final int vao;
    private final ManagedFloatBuffer polygonFaceBuffer;
    private final ManagedIntBuffer indexBuffer;
    private final ManagedIntBuffer ibo;
    private int currentLength;

    public PatchDrawer(GL4 gl, PatchLineDrawer patchLineDrawer) {
        currentLength = 0;
        lineDrawer = patchLineDrawer;

        drawableList = new ArrayList<>();

        shader = new ProgramObjectBuilder(gl)
                .vertex("/PolygonBG.vert")
                .fragment("/ColorID.frag")
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

        gl.glVertexArrayVertexBuffer(vao, 0, polygonFaceBuffer.buffer, 0, gPolygon.BYTE);
        gl.glVertexArrayElementBuffer(vao, indexBuffer.buffer);
    }

    @Override
    protected void syncInner(GL4 gl, Integer first, Integer last) {
        for (int i = first; i < last; ++i) {
            gPatch current = (gPatch)drawableList.get(i);
            lineDrawer.drawableList.set(i, current.getLine());
        }
        lineDrawer.syncInner(gl, first, last);

        polygonFaceBuffer.update(gl,toPackableFloat(drawableList),first,last);
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void syncInner(GL4 gl) {
        List<Drawable> sublist = drawableList.subList(syncedDrawable,drawableList.size());
        List<Drawable> lines = new ArrayList<>(sublist.size());

        int indexCount = 0;
        for (gPatch patch:(List<gPatch>)(Object)sublist) {
            lines.add(patch.getLine());
            indexCount += patch.indices.length;
        }
        indexCount *= 3;

        ArrayList<DrawElementsIndirectCommand> indirectCommands = new ArrayList<>(sublist.size());
        int[] indices = new int[indexCount];
        int position = 0;
        for (gPatch patch:(List<gPatch>)(Object)sublist) {
            indirectCommands.add(new DrawElementsIndirectCommand(patch.indices.length * 3, 1, currentLength, 0, 0));
            for (int i = 0; i < patch.indices.length; ++i) {
                indices[position++] = patch.indices[i][0] + currentLength;
                indices[position++] = patch.indices[i][1] + currentLength;
                indices[position++] = patch.indices[i][2] + currentLength;
            }
            currentLength += patch.indices.length * 3;
        }


        lineDrawer.add(lines);
        lineDrawer.sync(gl);

        polygonFaceBuffer.add(gl, toPackableFloat(sublist));
        indexBuffer.add(gl, indices);

        ibo.add(gl, toPackableInt(indirectCommands));
    }
    @Override
    protected void drawInner(GL4 gl) {
        gl.glBindVertexArray(vao);
        gl.glBindBuffer(GL_DRAW_INDIRECT_BUFFER, ibo.buffer);
        gl.glUseProgram(shader.ID);
        gl.glMultiDrawElementsIndirect(GL_TRIANGLES, GL_UNSIGNED_INT, null, syncedDrawable, 0);
    }
    @Override
    public Drawable.DrawableType requiredType() {
        return Drawable.DrawableType.Patch;
    }
}
