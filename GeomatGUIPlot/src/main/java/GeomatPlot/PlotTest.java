package GeomatPlot;

import GeomatPlot.Draw.gLabel;
import GeomatPlot.Draw.gLine;
import GeomatPlot.Draw.gPoint;
import GeomatPlot.Event.CreateEvent;
import GeomatPlot.PolygonCalc.Delaunay;
import GeomatPlot.PolygonCalc.Vertex;

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
        Plot plot = new Plot();
        gPoint p0 = new gPoint(new float[]{0f,0f,1f,1f,0f,0f,0f,1f});
        gPoint p1 = new gPoint(new float[]{5f,20f,1f,1f,0f,0f,0f,1f});
        plot.addDrawable(p0);
        plot.addDrawable(p1);
        gLabel label = new gLabel(0,0,"THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG ij");
        plot.addDrawable(label);

        for (int i = 0; i < 100; i++) {
            for (int j = 0; j < 100; j++) {
                //plot.addDrawable(new gPoint(new float[]{i * 0.01f,j * 0.01f,1f,1f,0f,0f,0f,1f}));
            }
            try {
                //Thread.sleep(100);
            }catch (Exception e) {

            }
        }

        gLine l1 = new gLine(new float[]{-1f,5f,10f,15f,20f,25f},new float[]{0f,20f,0f,20f,0f,20f},new float[]{0f,0f,0f,1f});
        plot.addDrawable(l1);
        try {
            Thread.sleep(1000);
            label.x -= 2;
            label.y += 2;
            plot.updateDrawable(label);
            //l1.x[0]--;
            //plot.callEvent(new UpdateLine(plot,l1.getID()));
            //plot.callEvent(new UpdateEvent(plot,l1));
            plot.updateDrawable(l1);
        }catch (Exception e) {

        }
        gLine l2 = new gLine(new float[]{0f,1f},new float[]{0f,1f},new float[][]{{0f, 1f, 0f, 1f},{0f,0f,1f,1f}});
        //plot.callEvent(new CreateLine(plot,l2));
        plot.addDrawable(l2);
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
}