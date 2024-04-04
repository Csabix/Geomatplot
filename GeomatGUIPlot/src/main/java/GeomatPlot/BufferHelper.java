package GeomatPlot;

import com.jogamp.opengl.GL4;

public class BufferHelper {
    public static int getNewCapacity(int oldCapacity, int position) {
        while (position > oldCapacity) {
            oldCapacity *= 2;
        }
        return oldCapacity;
    }
    public static void resizeBuffer(GL4 gl, int buffer, int oldPosition, int newCapacity, int usage) { // IN BYTES
        int tmp = GLObject.createBuffers(gl,1)[0];
        gl.glNamedBufferData(tmp,oldPosition,null,gl.GL_STREAM_COPY);
        gl.glCopyNamedBufferSubData(buffer,tmp,0,0,oldPosition);
        gl.glNamedBufferData(buffer,newCapacity,null,usage);
        gl.glCopyNamedBufferSubData(tmp,buffer,0,0,oldPosition);
        GLObject.deleteBuffers(gl,new int[]{tmp});
    }
}
