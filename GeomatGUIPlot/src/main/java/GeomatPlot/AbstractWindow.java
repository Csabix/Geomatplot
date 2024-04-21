package GeomatPlot;

import GeomatPlot.Event.EventAggregator;
import com.jogamp.opengl.*;
import com.jogamp.opengl.awt.GLCanvas;

import javax.swing.*;
import java.awt.*;
import java.awt.event.*;

import static java.awt.Frame.MAXIMIZED_BOTH;

public abstract class AbstractWindow {
    protected static int top,left,bot,right;
    public Frame frame;
    public GLCanvas canvas;
    private final GLContext context;
    private final EventAggregator eventAggregator;
    protected Boolean running;
    public Integer width, height;
    public  AbstractWindow(String title, Integer width, Integer height, Boolean maximized){
        createWindow(title,width,height,maximized);
        this.width = canvas.getWidth();
        this.height = canvas.getHeight();
        context = canvas.getContext();

        eventAggregator = new EventAggregator();
        frame.addWindowListener(new FrameWindowListener());
        frame.addComponentListener(new FrameComponentListener());
        CanvasMouseListener mouseListener = new CanvasMouseListener();
        canvas.addComponentListener(new CanvasComponentListener());
        canvas.addMouseListener(mouseListener);
        canvas.addMouseMotionListener(mouseListener);
        canvas.addMouseWheelListener(mouseListener);

        running = true;

        /*GL gl = getGl();
        gl.setSwapInterval(0);
        freeGL();*/
        Thread thread = new Thread(new Runnable() {
            @Override
            public void run() {
                AbstractWindow.this.mainLoop();
            }
        });
        thread.start();
    }
    protected abstract void init(GL4 gl);
    protected abstract void processEvent(GL4 gl,AWTEvent event);
    protected abstract void update(GL4 gl);
    protected abstract void draw(GL4 gl);
    public void callEvent(AWTEvent event) {
        EventQueue.invokeLater(new Runnable() {
            @Override
            public void run() {
                eventAggregator.addEvent(event);
            }
        });
    }
    public void toFront() {
        frame.toFront();
        frame.requestFocus();
    }
    private void mainLoop() {
        GL4 gl_ = getGl();
        init(gl_);
        freeGL();
        while (running) {
            GL4 gl = getGl();
            eventAggregator.getEvents().forEach((evt) -> processEvent(gl,evt));
            update(gl);
            draw(gl);
            freeGL();
            canvas.swapBuffers();
        }
        frame.dispose();
    }
    private GL4 getGl() {
        if(!context.isCurrent()){
            context.makeCurrent();
        }
        return context.getGL().getGL4();
    }
    private void freeGL() {
        if(context.isCurrent()){
            context.release();
        }
    }
    private void createWindow(String title, Integer width, Integer height, Boolean maximized){
        GLProfile profile = GLProfile.get("GL4");
        GLCapabilities capabilities = new GLCapabilities(profile);

        frame = new Frame();
        frame.setVisible(true);
        Insets insets = frame.getInsets();
        top = insets.top;
        left = insets.left;
        bot = insets.bottom;
        right = insets.right;

        canvas = new GLCanvas(capabilities);
        canvas.setBounds(left,top,width,height);

        frame.setLayout(null);
        frame.setSize(width+left+right, height+bot+top);
        frame.add(canvas);

        if (maximized){
            frame.setExtendedState(MAXIMIZED_BOTH);
            canvas.setBounds(left,top,frame.getWidth()-left-right,frame.getHeight()-bot-top);
        }
        frame.revalidate();
        frame.repaint();
        canvas.setAutoSwapBufferMode(false);
        canvas.display();
    }
    private class FrameWindowListener extends WindowAdapter {
        public FrameWindowListener() {
            super();
        }

        @Override
        public void windowClosing(WindowEvent windowEvent) {
            super.windowClosing(windowEvent);
            eventAggregator.addEvent(windowEvent);
        }
    }
    private class FrameComponentListener extends ComponentAdapter {
        Timer timer;
        public FrameComponentListener() {
            super();
            timer = new Timer(300, new ActionListener() {
                @Override
                public void actionPerformed(ActionEvent actionEvent) {
                    canvas.setBounds(left,top,frame.getWidth()-left-right,frame.getHeight()-bot-top);
                    frame.revalidate();;
                }
            });
        }

        @Override
        public void componentResized(ComponentEvent componentEvent) {
            super.componentResized(componentEvent);
            timer.restart();
        }
    }
    private class CanvasComponentListener extends ComponentAdapter {
        public CanvasComponentListener() {
            super();
        }

        @Override
        public void componentResized(ComponentEvent componentEvent) {
            super.componentResized(componentEvent);
            width = canvas.getWidth();
            height = canvas.getHeight();
            eventAggregator.addEvent(componentEvent);
        }
    }

    private class CanvasMouseListener extends MouseAdapter {
        public CanvasMouseListener() {
            super();
        }

        @Override
        public void mousePressed(MouseEvent mouseEvent) {
            super.mousePressed(mouseEvent);
            eventAggregator.addEvent(mouseEvent);
        }

        @Override
        public void mouseReleased(MouseEvent mouseEvent) {
            super.mouseReleased(mouseEvent);
            eventAggregator.addEvent(mouseEvent);
        }

        @Override
        public void mouseWheelMoved(MouseWheelEvent mouseWheelEvent) {
            super.mouseWheelMoved(mouseWheelEvent);
            eventAggregator.addEvent(mouseWheelEvent);
        }

        @Override
        public void mouseDragged(MouseEvent mouseEvent) {
            super.mouseDragged(mouseEvent);
            eventAggregator.addEvent(mouseEvent);
        }
    }
}

