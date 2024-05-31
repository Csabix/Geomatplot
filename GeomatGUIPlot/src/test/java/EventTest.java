import GeomatPlot.Draw.*;
import GeomatPlot.Plot;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.awt.event.WindowEvent;

class EventTest {
    Plot plot;
    @BeforeEach
    void setUp() {
        plot = new Plot();
    }

    @AfterEach
    void tearDown() {
        plot.frame.dispatchEvent(new WindowEvent(plot.frame, WindowEvent.WINDOW_CLOSING) );
    }

    void sleep500ms() {
        try{
            Thread.sleep(500);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    void normalOrderSingle(Drawable d1) {
        plot.addDrawable(d1);
        sleep500ms();
        plot.updateDrawable(d1);
        sleep500ms();
        plot.removeDrawable(d1);
        sleep500ms();
    }
    void normalOrder(Drawable d1, Drawable d2, Drawable d3, Drawable d4, Drawable d5) {
        plot.addDrawable(d1);
        plot.addDrawable(d2);
        plot.addDrawable(d3);
        plot.addDrawable(d4);
        plot.addDrawable(d5);
        sleep500ms();
        plot.updateDrawable(d1);
        plot.updateDrawable(d2);
        plot.updateDrawable(d3);
        plot.updateDrawable(d4);
        plot.updateDrawable(d5);
        sleep500ms();
        plot.removeDrawable(d1);
        plot.removeDrawable(d2);
        plot.removeDrawable(d3);
        plot.removeDrawable(d4);
        plot.removeDrawable(d5);
        sleep500ms();
    }

    void normalOrderSingleFast(Drawable d1) {
        plot.addDrawable(d1);
        plot.updateDrawable(d1);
        plot.removeDrawable(d1);
        sleep500ms();
    }
    void normalOrderFast(Drawable d1, Drawable d2, Drawable d3, Drawable d4, Drawable d5) {
        plot.addDrawable(d1);
        plot.addDrawable(d2);
        plot.addDrawable(d3);
        plot.addDrawable(d4);
        plot.addDrawable(d5);
        plot.updateDrawable(d1);
        plot.updateDrawable(d2);
        plot.updateDrawable(d3);
        plot.updateDrawable(d4);
        plot.updateDrawable(d5);
        plot.removeDrawable(d1);
        plot.removeDrawable(d2);
        plot.removeDrawable(d3);
        plot.removeDrawable(d4);
        plot.removeDrawable(d5);
        sleep500ms();
    }

    void duplicateEvent(Drawable d1) {
        plot.addDrawable(d1);
        plot.addDrawable(d1);
        plot.addDrawable(d1);
        sleep500ms();
        plot.updateDrawable(d1);
        plot.updateDrawable(d1);
        sleep500ms();
        plot.removeDrawable(d1);
        plot.removeDrawable(d1);
        plot.removeDrawable(d1);
        plot.removeDrawable(d1);
        sleep500ms();
    }

    void invalidDelete(Drawable d1, Drawable d2) {
        plot.addDrawable(d1);
        sleep500ms();
        plot.updateDrawable(d2);
        sleep500ms();
        plot.removeDrawable(d2);
        sleep500ms();
        plot.removeDrawable(d1);
        sleep500ms();
    }

    @Test
    void point() {
        gPoint p1 = new gPoint(0,1, true);
        gPoint p2 = new gPoint(1,0, false);
        gPoint p3 = new gPoint(1,1);
        gPoint p4 = new gPoint(2, 1, new float[]{0,0,0}, 30, 0, true);
        gPoint p5 = new gPoint(1, 2, new float[]{0,0,0}, 40, 1.5f, false);

        normalOrderSingleFast(p1);
        normalOrderFast(p1,p2,p3,p4,p5);
        normalOrderSingle(p1);
        normalOrder(p1,p2,p3,p4,p5);
        duplicateEvent(p1);
        invalidDelete(p2,p3);
    }

    @Test
    void line() {
        float[] x1 = new float[200];
        float[] y1 = new float[200];
        for (int i = 0; i < x1.length; i++) {
            x1[i] = i;
            y1[i] = i;
        }

        gLine l1 = new gLine(new float[]{0,0},new float[]{1,1},new float[][]{{0,0,0}},new float[]{5},true);
        gLine l2 = new gLine(x1,y1,new float[][]{{0,0,0}},new float[]{5},false);

        gLine l3 = new gLine(x1,y1,new float[][]{{0,0,0}},new float[]{5},true);
        gLine l4 = new gLine(x1,y1,new float[][]{{0,0,0}},new float[]{5},false);
        gLine l5 = new gLine(x1,y1,new float[][]{{0,0,0}},new float[]{5},false);

        normalOrderSingleFast(l1);
        normalOrderFast(l1,l2,l3,l4,l5);
        normalOrderSingle(l1);
        normalOrder(l1,l2,l3,l4,l5);
        duplicateEvent(l1);
        invalidDelete(l2,l3);
    }

    @Test
    void polygon() {
        gPolygon p1 = new gPolygon(new float[]{0,1,1,0},new float[]{2,2,3,3},new int[][]{{0, 1, 2},{0,2,3}},true);
        gPolygon p2 = new gPolygon(new float[]{1,2,2,1},new float[]{2,2,3,3},new int[][]{{0, 1, 2},{0,2,3}},false);
        gPolygon p3 = new gPolygon(new float[]{1,2,2,1},new float[]{2,2,3,3},new int[][]{{0, 1, 2},{0,2,3}},new float[][]{{0f,1f,0f}},new float[][]{{0f,0f,0f}},1f,true);
        gPolygon p4 = new gPolygon(new float[]{0,1,1},new float[]{2,2,3},new int[][]{{0, 1, 2}},false);
        gPolygon p5 = new gPolygon(new float[]{1,2,2},new float[]{2,2,3},new int[][]{{0, 1, 2}},true);

        normalOrderSingleFast(p1);
        normalOrderFast(p1,p2,p3,p4,p5);
        normalOrderSingle(p1);
        normalOrder(p1,p2,p3,p4,p5);
        duplicateEvent(p1);
        invalidDelete(p2,p3);
    }

    @Test
    void patch() {
        gPatch p1 = new gPatch(new float[]{0,1,1,0},new float[]{2,2,3,3},new int[][]{{0, 1, 2},{0,2,3}},true);
        gPatch p2 = new gPatch(new float[]{1,2,2,1},new float[]{2,2,3,3},new int[][]{{0, 1, 2},{0,2,3}},false);
        gPatch p3 = new gPatch(new float[]{1,2,2,1},new float[]{2,2,3,3},new int[][]{{0, 1, 2},{0,2,3}},new float[][]{{0f,1f,0f}},new float[][]{{0f,0f,0f}},1f,true);
        gPatch p4 = new gPatch(new float[]{0,1,1},new float[]{2,2,3},new int[][]{{0, 1, 2}},false);
        gPatch p5 = new gPatch(new float[]{1,2,2},new float[]{2,2,3},new int[][]{{0, 1, 2}},true);

        normalOrderSingleFast(p1);
        normalOrderFast(p1,p2,p3,p4,p5);
        normalOrderSingle(p1);
        normalOrder(p1,p2,p3,p4,p5);
        duplicateEvent(p1);
        invalidDelete(p2,p3);
    }

    @Test
    void label() {
        gLabel l1 = new gLabel(0,0,"the quick brown fox jumps over the lazy dog.");
        gLabel l2 = new gLabel(0,-1,"THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG.");
        gLabel l3 = new gLabel(0,1,"0123456789");
        gLabel l4 = new gLabel(0,-2,"some more text");
        gLabel l5 = new gLabel(0,2,"even more text");

        normalOrderSingleFast(l1);
        normalOrderFast(l1,l2,l3,l4,l5);
        normalOrderSingle(l1);
        normalOrder(l1,l2,l3,l4,l5);
        duplicateEvent(l1);
        invalidDelete(l2,l3);
    }
}