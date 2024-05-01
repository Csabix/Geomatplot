package GeomatPlot;

import GeomatPlot.Draw.*;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;

// https://undocumentedmatlab.com/articles/matlab-callbacks-for-java-events/
public class PlotTest {
    public static void main(String[] args) {
        Plot plot = new Plot();
        lineTest(plot);
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

        plot.addDrawable(l1);
        plot.updateDrawable(l1);
        try {
            Thread.sleep(100);
        } catch (Exception e) {

        }
        plot.removeDrawable(l1);
        plot.addDrawable(l2);
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