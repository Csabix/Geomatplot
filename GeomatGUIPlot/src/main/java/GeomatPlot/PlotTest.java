package GeomatPlot;

import GeomatPlot.Draw.*;

import java.io.BufferedReader;
import java.io.FileReader;

// https://undocumentedmatlab.com/articles/matlab-callbacks-for-java-events/
public class PlotTest {
    public static void main(String[] args) {
        Plot plot = new Plot();
        pointTest(plot);
        //lineTest(plot);
        //functionTest(plot);
        //labelTest(plot);
    }

    static void labelTest(Plot plot) {
        gLabel l1 = new gLabel(0,0,"the quick brown fox jumps over the lazy dog 0123456789");
        plot.addDrawable(l1);
        callSleep(5000);
        gLabel l2 = new gLabel(2,-2,"THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG 0123456789");
        plot.removeDrawable(l1);
        plot.addDrawable(l2);
        callSleep(5000);
        plot.setFont("C:/Windows/Fonts/Arial.ttf", true, false, 12);
        callSleep(5000);
        plot.removeDrawable(l2);
    }

    static void functionTest(Plot plot) {
        gPoint p0 = new gPoint(-1,0, true);
        gPoint p1 = new gPoint(1,0, true);
        gPoint p2 = new gPoint(0,-1, true);
        gPoint p3 = new gPoint(0,1, true);
        plot.addDrawable(p0);
        plot.addDrawable(p1);
        plot.addDrawable(p2);
        plot.addDrawable(p3);
        gFunction f1 = new gFunction("E:\\MProg\\Repos\\Geomatplot\\GeomatGUIPlot\\src\\main\\resources\\temp.frag", FunctionDrawer.Resolution.HALF);
        plot.addDrawable(f1);

        callSleep(5000);
        plot.removeDrawable(f1);
    }

    static void callSleep(int time) {
        try {
            Thread.sleep(time);
        } catch (Exception ignored) {

        }
    }

    static void pointTest(Plot plot) {
        gPoint p1 = new gPoint(0,0);
        plot.addDrawable(p1);
        callSleep(1000);
        plot.removeDrawable(p1);

        //List<gPoint> pointList = new ArrayList<>(1000*1000);
        gPoint[] points = new gPoint[1000*1000];
        int pos = 0;
        for (int i = 0; i < 1000; i++) {
            for (int j = 0; j < 1000; j++) {
                gPoint p = new gPoint(i * 0.01f,j * 0.01f);
                //plot.addDrawable(p);
                //pointList.add(p);
                points[pos++] = p;
            }
        }
        plot.addDrawable(points);

        callSleep(5000);
        System.out.println("Start");
        plot.removeDrawable(points);
        //pointList.forEach(plot::removeDrawable);
    }

    static void lineTest(Plot plot) {
        float[] x1 = new float[200];
        float[] y1 = new float[200];
        for (int i = 0; i < x1.length; i++) {
            x1[i] = i;
            y1[i] = i;
        }

        gLine l1 = new gLine(new float[]{0,0},new float[]{1,1},new float[][]{{0,0,0}},new float[]{5},false);
        gLine l2 = new gLine(x1,y1,new float[][]{{0,0,0}},new float[]{5},false);

        gLine l3 = new gLine(x1,y1,new float[][]{{0,0,0}},new float[]{5},false);
        gLine l4 = new gLine(x1,y1,new float[][]{{0,0,0}},new float[]{5},false);
        gLine l5 = new gLine(x1,y1,new float[][]{{0,0,0}},new float[]{5},false);
        gLine l6 = new gLine(x1,y1,new float[][]{{0,0,0}},new float[]{5},false);
        gLine l7 = new gLine(x1,y1,new float[][]{{0,0,0}},new float[]{5},false);

        plot.addDrawable(l1);
        plot.updateDrawable(l1);
        try {
            Thread.sleep(1000);
        } catch (Exception e) {

        }
        plot.removeDrawable(l1);
        plot.addDrawable(l2);

        plot.addDrawable(l3);
        plot.addDrawable(l3);
        plot.addDrawable(l4);
        plot.addDrawable(l5);
        plot.addDrawable(l6);
        plot.addDrawable(l7);
    }

    static void shrek(Plot p) {
        int i = 0;
        try (BufferedReader br = new BufferedReader(new FileReader("E:\\MProg\\Repos\\Geomatplot\\GeomatGUIPlot\\src\\main\\resources\\shrek.txt"))) {
            String line;
            while ((line = br.readLine()) != null) {
                gLabel label = new gLabel(0,-i, line);
                p.addDrawable(label);
                ++i;
            }
        } catch (Exception e) {

        }
    }
}