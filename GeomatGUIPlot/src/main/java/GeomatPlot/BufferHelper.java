package GeomatPlot;

import com.jogamp.opengl.GL4;

public class BufferHelper {
    public static int getNewCapacity(int oldCapacity, int position) {
        while (position >= oldCapacity) {
            oldCapacity *= 2;
        }
        return oldCapacity;
    }
    public static void resizeBuffer(GL4 gl, int buffer, int oldPosition, int newCapacity, int usage) { // IN BYTES
        // Resize the buffer while keeping the name and the data

        // Create new buffer with the size of the old
        int tmp = GLObject.createBuffers(gl,1)[0];
        gl.glNamedBufferData(tmp,oldPosition,null,gl.GL_STREAM_COPY);
        // Copy the old buffers data into the new
        gl.glCopyNamedBufferSubData(buffer,tmp,0,0,oldPosition);
        // Resize the old buffer
        gl.glNamedBufferData(buffer,newCapacity,null,usage);
        // Copy back the data
        gl.glCopyNamedBufferSubData(tmp,buffer,0,0,oldPosition);
        // Delete the new buffer
        GLObject.deleteBuffers(gl,new int[]{tmp});
    }
}
