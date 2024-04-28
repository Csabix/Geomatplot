package GeomatPlot.Draw;

import GeomatPlot.DrawElementsIndirectCommand;
import GeomatPlot.GLObject;
import GeomatPlot.Mem.ManagedFloatBuffer;
import GeomatPlot.Mem.ManagedIntBuffer;
import GeomatPlot.Mem.PackableInt;
import GeomatPlot.ProgramObject;
import GeomatPlot.ProgramObjectBuilder;
import com.jogamp.opengl.GL4;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static com.jogamp.opengl.GL.GL_TRIANGLES;
import static com.jogamp.opengl.GL.GL_UNSIGNED_INT;
import static com.jogamp.opengl.GL3ES3.GL_DRAW_INDIRECT_BUFFER;

public class PolygonDrawer extends Drawer{
    private static class Indices implements PackableInt {
        public int[] indices;
        public Indices(int[][] indices, int add) {
            this.indices =  Arrays.stream(indices)
                            .flatMapToInt(Arrays::stream)
                            .map((i)->i++)
                            .toArray();
        }

        @Override
        public int[] pack() {
            return indices;
        }

        @Override
        public int bytes() {
            return indices.length * Integer.BYTES;
        }
    }
    private static final int INITIAL_CAPACITY = 100 * gPolygon.BYTE;
    private final LineDrawer<gLine> lineDrawer;
    private final PointDrawer pointDrawer;
    private final ProgramObject shader;
    private final int vao;
    private final ManagedFloatBuffer polygonFaceBuffer;
    private final ManagedIntBuffer indexBuffer;
    private final ManagedIntBuffer ibo;
    private int currentLength;

    public PolygonDrawer(GL4 gl) {
        currentLength = 0;
        lineDrawer = new LineDrawer<>(gl);
        pointDrawer = new PointDrawer(gl);
        lineDrawer.overrideDrawID(getDrawID());
        pointDrawer.overrideDrawID(getDrawID());

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

    }

    @SuppressWarnings("unchecked")
    @Override
    protected void syncInner(GL4 gl) {
        polygonFaceBuffer.add(gl, toPackableFloat(drawableList.subList(syncedDrawable, drawableList.size())));
        int indexCount = 0;
        for (int i = syncedDrawable; i < drawableList.size(); i++) {
            gPolygon current = (gPolygon)drawableList.get(i);
            List<Drawable> points = (List<Drawable>)(Object)current.getPoints();
            gLine line = current.getLine();
            pointDrawer.add(points);
            lineDrawer.add(Collections.singletonList(line));
            indexCount += 3 * current.indices.length;
        }

        ArrayList<DrawElementsIndirectCommand> indirectCommands = new ArrayList<>(drawableList.size() - syncedDrawable);
        int[] indices = new int[indexCount];
        int position = 0;
        for (int i = syncedDrawable; i < drawableList.size(); i++) {
            gPolygon current = (gPolygon)drawableList.get(i);
            indirectCommands.add(new DrawElementsIndirectCommand(current.indices.length * 3, 1, currentLength, 0, 0));
            for (int j = 0; j < current.indices.length; j++) {
                indices[position++] = current.indices[j][0] + currentLength;
                indices[position++] = current.indices[j][1] + currentLength;
                indices[position++] = current.indices[j][2] + currentLength;
            }
            currentLength += current.indices.length * 3;
        }
        indexBuffer.add(gl, indices);

        pointDrawer.sync(gl);
        lineDrawer.sync(gl);

        ibo.add(gl, toPackableInt(indirectCommands));
    }

    @Override
    protected void drawInner(GL4 gl) {
        gl.glBindVertexArray(vao);
        gl.glBindBuffer(GL_DRAW_INDIRECT_BUFFER, ibo.buffer);
        gl.glUseProgram(shader.ID);
        gl.glMultiDrawElementsIndirect(GL_TRIANGLES, GL_UNSIGNED_INT, null, syncedDrawable, 0);
        lineDrawer.draw(gl);
        pointDrawer.draw(gl);
    }

    @Override
    public Drawable.DrawableType requiredType() {
        return Drawable.DrawableType.Polygon;
    }
}
