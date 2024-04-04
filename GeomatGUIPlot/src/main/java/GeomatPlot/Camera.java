package GeomatPlot;

import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;

import static com.jogamp.opengl.GL.GL_MAP_WRITE_BIT;
import static com.jogamp.opengl.GL2ES3.GL_UNIFORM_BUFFER;

public class Camera {
    private boolean needSync;
    private final int ubo;
    private float[] data; // vec2 scale, vec2 translate, zoom, width
    private float[] oldData;
    public Camera(GL4 gl, float w, float h, float zoom, float x, float y) {
        needSync = true;
        data = new float[]{2f / (zoom * w/h), 2f / zoom, x, y, w, h};

        ubo = GLObject.createBuffers(gl,1)[0];
        gl.glBindBuffer(GL_UNIFORM_BUFFER, ubo);
        gl.glBufferStorage(GL_UNIFORM_BUFFER, data.length * Float.BYTES, null, GL_MAP_WRITE_BIT);
        gl.glBindBuffer(GL_UNIFORM_BUFFER, 0);

        sync(gl);

        gl.glBindBufferRange(GL_UNIFORM_BUFFER, 0, ubo, 0, data.length * Float.BYTES);
    }
    public void sync(GL4 gl) {
        if(needSync) {
            ByteBuffer byteBuffer = gl.glMapNamedBufferRange(ubo, 0, data.length * Float.BYTES, GL_MAP_WRITE_BIT);
            byteBuffer.asFloatBuffer().put(data);
            gl.glUnmapNamedBuffer(ubo);
            needSync = false;
        }
    }
    public Tuple<Float,Float> invert(float x, float y) {
        return new Tuple<>(x/data[0] + data[2],y/data[1] + data[3]);
    }
    public float getX() {
        return data[2];
    }
    public float getY() {
        return data[3];
    }
    public float getZoom() {
        return 1 / data[1] * 2;
    }
    public float getWidth(){
        return data[4];
    }
    public float getHeight(){
        return data[5];
    }
    public void setX(float x) {
        needSync = true;
        data[2] = x;
    }
    public void setY(float y) {
        needSync = true;
        data[3] = y;
    }
    public void setZoom(float zoom) {
        needSync = true;
        data[0] = 2f/(zoom * getWidth() / getHeight());
        data[1] = 2/zoom;
    }
    public void setWidth(float w) {
        needSync = true;
        data[4] = w;
        data[0] = 2f / (getZoom() * w/getHeight());
    }
    public void setHeight(float h) {
        needSync = true;
        data[5] = h;
        data[0] = 2f / (getZoom() * getWidth()/h);
    }
    public void setOldData() {
        oldData = data.clone();
    }
    public void swap() {
        float[] tmp = oldData;
        oldData = data;
        data = tmp;
    }
}
