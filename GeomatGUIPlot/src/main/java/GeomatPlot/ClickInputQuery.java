package GeomatPlot;

import java.awt.event.MouseEvent;

import static java.awt.event.InputEvent.*;

public class ClickInputQuery {
    private Plot plt;
    private int button;
    private int modifiers;
    protected boolean waitingInput;
    public int[] xyScreen;
    public float[] xy;
    public ClickInputQuery(Plot plt) {
        this.plt = plt;
    }
    protected synchronized void setEvent(MouseEvent event, Camera camera) {
        button = event.getButton();
        modifiers = event.getModifiersEx();
        xyScreen = new int[]{event.getX(), plt.height - event.getY()};
        Tuple<Float, Float> coords = camera.invert(event.getX() / (float)plt.width * 2f - 1f, (plt.height - event.getY()) / (float)plt.height * 2f - 1f);
        xy = new float[]{coords.first, coords.second};
        waitingInput = false;
        this.notifyAll();
    }
    public boolean isButton(int x) {
        // 1 Left, 2 Right, 3 Middle, etc...
        return button == x;
    }
    public boolean isDownAlt() {
        return (modifiers & ALT_DOWN_MASK) > 0;
    }
    public boolean isDownShift() {
        return (modifiers & SHIFT_DOWN_MASK) > 0;
    }
    public boolean isDownCTRL() {
        return (modifiers & CTRL_DOWN_MASK) > 0;
    }
    public synchronized void getInput() {
        plt.toFront();
        waitingInput = true;
        try {
            this.wait();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    public synchronized boolean isWaitingInput() {
        return waitingInput;
    }
}