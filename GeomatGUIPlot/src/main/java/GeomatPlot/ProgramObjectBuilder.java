package GeomatPlot;

import com.jogamp.opengl.GL4;

import java.util.ArrayList;
import java.util.List;

public class ProgramObjectBuilder {
    private final List<ProgramObject.ShaderStage> stageList;
    private final GL4 gl;
    public ProgramObjectBuilder(GL4 gl){
        stageList = new ArrayList<>();
        this.gl = gl;
    }
    public ProgramObjectBuilder vertex(String path){
        stageList.add(new ProgramObject.ShaderStage(gl.GL_VERTEX_SHADER,path));
        return this;
    }
    public ProgramObjectBuilder tessControl(String path){
        stageList.add(new ProgramObject.ShaderStage(gl.GL_TESS_CONTROL_SHADER,path));
        return this;
    }
    public ProgramObjectBuilder tessEvaluation(String path){
        stageList.add(new ProgramObject.ShaderStage(gl.GL_TESS_EVALUATION_SHADER,path));
        return this;
    }
    public ProgramObjectBuilder geometry(String path){
        stageList.add(new ProgramObject.ShaderStage(gl.GL_GEOMETRY_SHADER,path));
        return this;
    }
    public ProgramObjectBuilder fragment(String path){
        stageList.add(new ProgramObject.ShaderStage(gl.GL_FRAGMENT_SHADER,path));
        return this;
    }
    public ProgramObject build(){
        return new ProgramObject(gl,stageList);
    }

    public ProgramObjectBuilder fragmentUserDefined(String path){
        stageList.add(new ProgramObject.ShaderStage(gl.GL_FRAGMENT_SHADER,path,false));
        return this;
    }
}
