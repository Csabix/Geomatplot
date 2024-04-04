package GeomatPlot;

import com.jogamp.common.nio.Buffers;
import com.jogamp.opengl.GL4;

import java.nio.ByteBuffer;
import java.nio.IntBuffer;
import java.util.Arrays;

public class GLObject {
    public static final Integer MAX_OBJECT_CREATION = 5;
    private static final IntBuffer buffer = Buffers.newDirectIntBuffer(MAX_OBJECT_CREATION);
    /*static {
        ByteBuffer b = ByteBuffer.allocateDirect(MAX_OBJECT_CREATION * Integer.BYTES);
        buffer = b.asIntBuffer();
    }*/
    private static void checkCount(Integer count) {
        if(count > MAX_OBJECT_CREATION || count < 0) throw new RuntimeException("Invalid number of object created");
    }
    private static int[] getValues(Integer count) {
        int[] objects = new int[count];
        buffer.get(objects);
        buffer.rewind();
        return Arrays.stream(objects).limit(count).toArray();
    }
    private static void setValues(int[] objects) {
        buffer.put(objects);
        buffer.rewind();
    }
    public synchronized static int[] createBuffers(GL4 gl, Integer count) {
        checkCount(count);
        gl.glCreateBuffers(count, buffer);
        return getValues(count);
    }
    public synchronized static void deleteBuffers(GL4 gl, int[] objects) {
        checkCount(objects.length);
        setValues(objects);
        gl.glDeleteBuffers(objects.length, buffer);
    }
    public synchronized static int[] createFrameBuffers(GL4 gl, Integer count) {
        checkCount(count);
        gl.glCreateFramebuffers(count, buffer);
        return getValues(count);
    }
    public synchronized static void deleteFrameBuffers(GL4 gl, int[] objects) {
        checkCount(objects.length);
        setValues(objects);
        gl.glDeleteFramebuffers(objects.length, buffer);
    }
    public synchronized static int[] createVertexArrays(GL4 gl, Integer count) {
        checkCount(count);
        gl.glCreateVertexArrays(count, buffer);
        return getValues(count);
    }
    public synchronized static void deleteVertexArrays(GL4 gl, int[] objects) {
        checkCount(objects.length);
        setValues(objects);
        gl.glDeleteVertexArrays(objects.length, buffer);
    }
    public synchronized static int[] createRenderBuffers(GL4 gl, Integer count) {
        checkCount(count);
        gl.glCreateRenderbuffers(count, buffer);
        return getValues(count);
    }
    public synchronized static void deleteRenderBuffers(GL4 gl, int[] objects) {
        checkCount(objects.length);
        setValues(objects);
        gl.glDeleteRenderbuffers(objects.length, buffer);
    }
    public synchronized static int[] createTextures(GL4 gl, int target, Integer count) {
        checkCount(count);
        gl.glCreateTextures(target,count,buffer);
        return getValues(count);
    }
    public synchronized static void deleteTextures(GL4 gl, int[] objects) {
        checkCount(objects.length);
        setValues(objects);
        gl.glDeleteTextures(objects.length,buffer);
    }
}