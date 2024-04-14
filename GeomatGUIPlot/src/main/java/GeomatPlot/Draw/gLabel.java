package GeomatPlot.Draw;

import GeomatPlot.Font.FontMap;
import GeomatPlot.Font.Letter;

import java.util.List;
public class gLabel extends Drawable {
    //private final List<Letter> letters;
    private final String text;
    public FontMap fontMap;
    public float x,y; // Anchor
    public int id;
    public gLabel(int x, int y, String text) {
        this.x = x;
        this.y = y;
        //this.letters = letters;
        this.text = text;
    }
    public gLabel(){
        //letters = null;
        text = "";
    }
    @Override
    public float[] pack() {
        List<Letter> letters = fontMap.createLabel(text);
        float[] data = new float[elementCount()];
        for (int i = 0; i < letters.size(); i++) {
            System.arraycopy(letters.get(i).pack(x,y), 0, data, i * Letter.ELEMENT_COUNT, Letter.ELEMENT_COUNT);
        }
        return data;
    }
    @Override
    public int elementCount() {
        return Letter.ELEMENT_COUNT * letterCount();
    }
    @Override
    public int elementCountVertex() {
        return Letter.ELEMENT_COUNT;
    }
    @Override
    public int bytes() {
        return Letter.BYTES * letterCount();
    }
    @Override
    public int bytesVertex() {
        return Letter.BYTES;
    }
    @Override
    public DrawableType getType() {
        return DrawableType.Label;
    }
    public int letterCount() {
        int sum = 0;
        for(char c : text.toCharArray()) {
            if(c != ' ') ++sum;
        }
        return sum;
    }
}
