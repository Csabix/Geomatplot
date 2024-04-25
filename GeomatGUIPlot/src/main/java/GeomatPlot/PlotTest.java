package GeomatPlot;

import GeomatPlot.Draw.*;
import GeomatPlot.Event.CreateEvent;
import GeomatPlot.PolygonCalc.Delaunay;
import GeomatPlot.PolygonCalc.Vertex;

import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.FileReader;
import java.io.ObjectOutputStream;
import java.nio.ByteBuffer;
import java.nio.FloatBuffer;
import java.util.Arrays;
import java.util.List;

// https://undocumentedmatlab.com/articles/matlab-callbacks-for-java-events/
public class PlotTest {
    public static void main(String[] args) {
        /*Vertex a = new Vertex(); a.x = 0; a.y = 0;
        Vertex b = new Vertex(); b.x = 5; a.y = 0;
        Vertex c = new Vertex(); c.x = 5; c.y = 5;
        List<Vertex> vertexList = Arrays.asList(a,b,c);
        Delaunay delaunay = new Delaunay(vertexList);
        delaunay.calc();
        List<Vertex> asd = delaunay.triangulate();
        for (Vertex v:asd) {
            System.out.println(v.x + " " + v.y);
        }*/
        gPatch patch = new gPatch(new float[]{0,1,1},new float[]{0,0,1},new float[][]{{0,0,0,1}},new float[][]{{0,1,1,1}},new int[][]{{0, 1, 2}});
        Plot plot = new Plot();
        plot.addDrawable(patch);
        shrek(plot);
        gPoint p0 = new gPoint(-1,0, true);
        gPoint p1 = new gPoint(5, 20, true);
        plot.addDrawable(p0);
        plot.addDrawable(p1);
        gLabel label = new gLabel(0,0,"THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG 01234");
        gLabel label2 = new gLabel(0,0,"the quick brown fox jumps over the lazy dog 56789");
        //gLabel label = new gLabel(0,0,"g");
        plot.addDrawable(label);
        plot.addDrawable(label2);

        gPolygon poly = new gPolygon(new float[]{0,1,1}, new float[]{-1,-1,0},new int[]{0,2,1},new float[]{0.3f,0.2f,0.2f});
        //plot.addDrawable(poly);

        /*for (int i = 0; i < 1000; i++) {
            for (int j = 0; j < 1000; j++) {
                plot.addDrawable(new gPoint(i * 0.01f,j * 0.01f, true));
            }
            try {
                //Thread.sleep(100);
            }catch (Exception e) {

            }
        }*/

        gLine l1 = new gLine(new float[]{-1f,5f,10f,15f,20f,25f},new float[]{0f,20f,0f,20f,0f,20f},new float[]{0f,0f,0f,1f},true);
        plot.addDrawable(l1);
        try {
            Thread.sleep(1000);
            label.x -= 2;
            label.y += 2;
            plot.updateDrawable(label);
            //l1.x[0]--;
            //plot.callEvent(new UpdateLine(plot,l1.getID()));
            //plot.callEvent(new UpdateEvent(plot,l1));
            //plot.updateDrawable(l1);
        }catch (Exception e) {

        }
        gLine l2 = new gLine(new float[]{0f,1f,2f},new float[]{0f,1f,2f},new float[]{0f, 1f, 0f, 1f},false);
        plot.addDrawable(l2);
        gLine l3 = new gLine(new float[]{2f,3f},new float[]{0f,1f},new float[]{0f, 1f, 0f, 1f},true);
        plot.addDrawable(l3);
        try {
            Thread.sleep(1000);
            //System.out.println(l1.ID);
            //System.out.println(l2.ID);
            //l1.x[0]--;
            //plot.callEvent(new UpdateLine(plot,l1.getID()));
            //plot.callEvent(new UpdateEvent(plot,l1));
            plot.updateDrawable(l1);
        }catch (Exception e) {

        }
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