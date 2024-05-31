package GeomatPlot.Draw;

import com.jogamp.opengl.GL4;

import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;
import java.util.List;

import static com.jogamp.opengl.GL.GL_TRIANGLES;
import static com.jogamp.opengl.GL.GL_UNSIGNED_INT;
import static com.jogamp.opengl.GL3ES3.GL_DRAW_INDIRECT_BUFFER;

public class PolygonDrawer extends PatchDrawer{
    PolygonPointDrawer pointDrawer;
    public PolygonDrawer(GL4 gl, PatchLineDrawer patchLineDrawer, PolygonPointDrawer polygonPointDrawer) {
        super(gl, patchLineDrawer);
        pointDrawer = polygonPointDrawer;
    }

    @SuppressWarnings("unchecked")
    @Override
    protected void syncInner(GL4 gl, int start) {
        super.syncInner(gl, start);
        List<gPolygon> subList = (List<gPolygon>)(Object)syncedDrawables.subList(start, syncedDrawables.size());
        List<Drawable> newPoints = new ArrayList<>();
        for (gPolygon polygon:subList) {
            Collections.addAll(newPoints, polygon.getPoints());
        }
        pointDrawer.add(newPoints);

    }

    @SuppressWarnings("unchecked")
    @Override
    protected void syncInner(GL4 gl, int first, int last) {
        super.syncInner(gl, first, last);
        List<Drawable> points = new LinkedList<Drawable>();
        for ( gPolygon polygon: (List<gPolygon>)(Object)syncedDrawables.subList(first,last)) {
            gPolygonPoint[] polygonPoints = polygon.points;
            for (gPolygonPoint p:polygonPoints) {
                p.x = polygon.x[p.getPolygonID()];
                p.y = polygon.y[p.getPolygonID()];
            }
            Collections.addAll(points, polygonPoints);

        }
        pointDrawer.update(points);
        pointDrawer.sync(gl);
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
    protected void deleteInner(GL4 gl, int[] IDs) {
        super.deleteInner(gl, IDs);

        List<Drawable> points = new LinkedList<>();
        for (int id : IDs) {
            Collections.addAll(points, ((gPolygon) syncedDrawables.get(id)).points);
        }
        pointDrawer.remove(points);
        pointDrawer.sync(gl);
    }

    @Override
    public DrawableType requiredType() {
        return DrawableType.Polygon;
    }
}
