package GeomatPlot;

import GeomatPlot.Draw.*;
import GeomatPlot.Event.CreateEvent;
import GeomatPlot.Event.DeleteEvent;
import GeomatPlot.Event.UpdateEvent;
import GeomatPlot.Font.FontMap;
import com.jogamp.opengl.GL4;
import com.jogamp.opengl.util.GLBuffers;

import java.awt.AWTEvent;
import java.awt.event.MouseEvent;
import java.awt.event.MouseWheelEvent;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.util.Optional;

import static com.jogamp.opengl.GL.*;
import static com.jogamp.opengl.GL2ES2.GL_INT;
import static com.jogamp.opengl.GL2ES3.GL_R32I;
import static com.jogamp.opengl.GL2ES3.GL_RED_INTEGER;
import static java.awt.event.ComponentEvent.COMPONENT_RESIZED;
import static java.awt.event.MouseEvent.*;
import static java.awt.event.WindowEvent.WINDOW_CLOSING;

public class Plot extends AbstractWindow{
    private Camera camera;
    private DrawerContainer drawerContainer;
    private Tuple<Float,Float> clickLocation;
    private boolean resized;
    private boolean fboCreated;
    private int fbo,colorTex,indexTex;
    private final IntBuffer readValue = GLBuffers.newDirectIntBuffer(1);
    public final ClickInputQuery clickInputQuery;
    private Movement movement;
    private FontMap fontMap;
    public Plot(){
        super("GeomatPLot",640,640,false);
        clickLocation = new Tuple<>(0f,0f);
        resized = false;
        fboCreated = false;
        clickInputQuery = new ClickInputQuery(this);
        movement = null;
    }
    @Override
    protected void init(GL4 gl) {
        gl.glClearColor(1,1,1,0);
        gl.glEnable(GL_BLEND);
        gl.glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        gl.glLineWidth(2f);

        camera = new Camera(gl, width, height, 10, 0, 0);

        fontMap = new FontMap(gl);
        drawerContainer = new DrawerContainer(gl,this, fontMap);

        resize(gl,canvas.getSurfaceWidth(),canvas.getSurfaceHeight());
    }
    private boolean drag = true;
    @Override
    protected void processEvent(GL4 gl,AWTEvent event) {
        switch (event.getID()) {
            case WINDOW_CLOSING:
                running = false;
                break;
            case CreateEvent.CREATE_EVENT:
                drawerContainer.callAdd((CreateEvent)event);
                break;
            case UpdateEvent.UPDATE_EVENT:
                drawerContainer.callUpdate((UpdateEvent)event);
                break;
            case DeleteEvent.DELETE_EVENT:
                drawerContainer.callRemove((DeleteEvent)event);
                break;
            case MOUSE_PRESSED:
                MouseEvent evt = (MouseEvent)event;

                if(clickInputQuery.isWaitingInput()) {
                    clickInputQuery.setEvent(evt, camera);
                    drag = false;
                    break;
                }
                drag = true;

                clickLocation = camera.invert(evt.getX() / (float) width * 2f - 1f, (height - evt.getY()) / (float) height * 2f - 1f);

                gl.glGetTextureSubImage(indexTex, 0, evt.getX(), height - evt.getY(), 0, 1, 1, 1, GL_RED_INTEGER, GL_INT, Float.BYTES, readValue);
                int typeID = readValue.get();
                readValue.rewind();

                Optional<ObjectClicked> result = drawerContainer.getClicked(typeID);

                if(result.isPresent() && result.get().data.isMovable()) {
                    ObjectClicked objectClicked = result.get();
                    System.out.println(objectClicked.type.toString() + " " + objectClicked.data.getID());
                    movement = new Movement(objectClicked.data, clickLocation.first, clickLocation.second);
                } else {
                    camera.setOldData();
                }
                break;
            case MOUSE_DRAGGED:
                if(!drag)return;
                evt = (MouseEvent)event;
                Tuple<Float,Float> location;

                if(movement == null) {
                    camera.swap();
                    location = camera.invert(evt.getX() / (float)width * 2f - 1f, (height - evt.getY()) / (float)height * 2f - 1f);
                    location.first = camera.getX() - location.first + clickLocation.first;
                    location.second = camera.getY() - location.second + clickLocation.second;
                    camera.swap();
                    camera.setX(location.first);
                    camera.setY(location.second);
                } else {
                    location = camera.invert(evt.getX() / (float)width * 2f - 1f, (height - evt.getY()) / (float)height * 2f - 1f);
                    movement.drag(this, location.first, location.second);
                }
                break;
            case MOUSE_RELEASED:
                movement = null;
                break;
            case COMPONENT_RESIZED:
                resized = true;
                break;
            case MOUSE_WHEEL:
                camera.setZoom(camera.getZoom() * (1f + ((MouseWheelEvent)event).getWheelRotation() / 100f));
                break;
        }
    }
    @Override
    protected void update(GL4 gl) {
        if (resized) {
            resize(gl, canvas.getSurfaceWidth(), canvas.getSurfaceHeight());
            resized = false;
        }
        drawerContainer.callSync(gl);
        camera.sync(gl);
    }
    private static final FloatBuffer colorClear = GLBuffers.newDirectFloatBuffer(new float[]{1f,1f,1f,0f});
    private static final IntBuffer indexClear = GLBuffers.newDirectIntBuffer(new int[]{-1});
    @Override
    protected void draw(GL4 gl) {
        gl.glClearTexImage(colorTex,0,GL_RGBA,GL_FLOAT,colorClear);
        gl.glClearTexImage(indexTex,0,GL_RED_INTEGER,GL_INT,indexClear);
        gl.glBindFramebuffer(GL_FRAMEBUFFER,fbo);

        drawerContainer.callDraw(gl);

        int w = canvas.getSurfaceWidth();
        int h = canvas.getSurfaceHeight();
        gl.glBlitNamedFramebuffer(fbo,0,0,0,w,h,0,0,w,h,GL_COLOR_BUFFER_BIT,GL_NEAREST);
    }
    public float[] clickInput() {
        toFront();
        clickInputQuery.getInput();
        return clickInputQuery.xy;
    }
    public void addDrawable(Drawable drawable) {
        callEvent(new CreateEvent(this,drawable));
    }
    public void addDrawable(Drawable[] drawables) {
        callEvent(new CreateEvent(this, drawables));
    }
    public void updateDrawable(Drawable drawable) {
        callEvent(new UpdateEvent(this,drawable));
    }
    public void updateDrawable(Drawable[] drawables) {
        callEvent(new UpdateEvent(this,drawables));
    }
    public void removeDrawable(Drawable drawable){
        callEvent(new DeleteEvent(this, drawable));
    }
    public void removeDrawable(Drawable[] drawables){
        callEvent(new DeleteEvent(this, drawables));
    }
    private void resize(GL4 gl,int sWidth, int sHeight) {
        gl.glViewport(0,0,sWidth,sHeight);
        camera.setWidth(sWidth);
        camera.setHeight(sHeight);

        if(fboCreated) {
            GLObject.deleteTextures(gl,new int[]{colorTex,indexTex});
            GLObject.deleteFrameBuffers(gl,new int[]{fbo});
        }
        int[] textures = GLObject.createTextures(gl,gl.GL_TEXTURE_2D,2);
        fbo = GLObject.createFrameBuffers(gl,1)[0];
        colorTex = textures[0];
        indexTex = textures[1];

        gl.glTextureParameteri(colorTex, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        gl.glTextureParameteri(colorTex, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        gl.glTextureParameteri(colorTex, GL_TEXTURE_WRAP_S,     GL_CLAMP_TO_EDGE);
        gl.glTextureParameteri(colorTex, GL_TEXTURE_WRAP_T,     GL_CLAMP_TO_EDGE);
        gl.glTextureStorage2D(colorTex, 1, GL_RGBA8, sWidth, sHeight);

        gl.glTextureParameteri(indexTex, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        gl.glTextureParameteri(indexTex, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        gl.glTextureParameteri(indexTex, GL_TEXTURE_WRAP_S,     GL_CLAMP_TO_EDGE);
        gl.glTextureParameteri(indexTex, GL_TEXTURE_WRAP_T,     GL_CLAMP_TO_EDGE);
        gl.glTextureStorage2D(indexTex, 1, GL_R32I, sWidth, sHeight);

        gl.glNamedFramebufferTexture(fbo,GL_COLOR_ATTACHMENT0,colorTex,0);
        gl.glNamedFramebufferTexture(fbo,GL_COLOR_ATTACHMENT0+1,indexTex,0);

        gl.glNamedFramebufferDrawBuffers(fbo,2, new int[]{GL_COLOR_ATTACHMENT0,GL_COLOR_ATTACHMENT0+1},0);

        fboCreated = true;

        this.updateDrawable(new gFunction());
    }

    public void setFont(String path, boolean bold, boolean italic, int size) {
        fontMap.setFont(path, bold, italic, size);
    }

    public int getFBO() {
        return fbo;
    }
}