package GeomatPlot;

import com.jogamp.opengl.GL4;
import com.jogamp.opengl.util.GLBuffers;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.ByteBuffer;
import java.nio.IntBuffer;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import static com.jogamp.opengl.GL.GL_FALSE;
import static com.jogamp.opengl.GL2ES2.*;

public class ProgramObject {
    public int ID;
    protected Map<String,Integer> uniformLocations;

    public void use(GL4 gl){
        gl.glUseProgram(ID);
    }
    public void unuse(GL4 gl){
        gl.glUseProgram(0);
    }
    public Integer getUniformLocation(GL4 gl, String uniform){
        Integer location = uniformLocations.get(uniform);
        if(location == null){
            location = gl.glGetUniformLocation(ID,uniform);
            uniformLocations.put(uniform,location);
        }
        return location;
    }
    protected static class ShaderStage {
        int stage;
        String path;
        public ShaderStage(int stage, String path){
            this.stage = stage;
            this.path = path;
        }
    }
    protected ProgramObject(GL4 gl, List<ShaderStage> stageInfos) {
        uniformLocations = new HashMap<>();

        ID = gl.glCreateProgram();
        int[] stages = new int[stageInfos.size()];
        for (int i = 0; i < stageInfos.size(); i++) {
            stages[i] = gl.glCreateShader(stageInfos.get(i).stage);
            try (InputStream in = getClass().getResourceAsStream(stageInfos.get(i).path)){
                BufferedReader reader = new BufferedReader(new InputStreamReader(in));
                String[] lines = {reader.lines().collect(Collectors.joining("\n"))};
                IntBuffer length = GLBuffers.newDirectIntBuffer(new int[]{lines[0].length()});
                gl.glShaderSource(stages[i],1, lines,length);
            } catch (Exception e) {
                System.out.println("Failed to read file");
            }

            gl.glCompileShader(stages[i]);
            gl.glAttachShader(ID,stages[i]);
        }

        gl.glLinkProgram(ID);

        int[] result = new int[1];
        int[] logLen = new int[1];
        gl.glGetProgramiv(ID,GL_LINK_STATUS,result,0);
        gl.glGetProgramiv(ID,GL_INFO_LOG_LENGTH,logLen,0);
        if(result[0] == GL_FALSE && logLen[0] != 0) {
            ByteBuffer byteBuffer = ByteBuffer.allocate(logLen[0]);
            gl.glGetProgramInfoLog(ID,logLen[0],null,byteBuffer);
            byteBuffer.rewind();
            for (int i = 0; i < logLen[0]-1; i++) {
                System.out.print((char)byteBuffer.get());
            }
        }

        for (int stage : stages) gl.glDeleteShader(stage);
    }
}
