package GeomatPlot.Font;

import GeomatPlot.GLObject;
import GeomatPlot.Draw.gLabel;
import com.jogamp.opengl.GL4;
import com.jogamp.opengl.util.texture.TextureData;
import com.jogamp.opengl.util.texture.awt.AWTTextureIO;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

import static com.jogamp.opengl.GL.*;
import static java.lang.Math.pow;

public class FontMap {
    //HashMap<Character, CharacterInfo> charInfoMap;
    private static final int asciiStart = 32;
    private static final int asciiEnd = 256;
    CharacterInfo[] charInfos;
    public FontMap(GL4 gl) {
        generateBitmap(gl,"C:/Windows/Fonts/Arial.ttf", 24);
    }
    public List<Letter> createLabel(String text) {
        List<Letter> letters = new ArrayList<>(text.length());

        int pixelX = 0;

        char[] chars = text.toCharArray();
        for (char aChar : chars) {
            CharacterInfo charInfo = charInfos[aChar - asciiStart];
            if(charInfo.id != ' ')letters.add(new Letter(charInfo, pixelX));
            pixelX += charInfo.width;
        }
        return letters;
        //return new gLabel(x,y,letters,"ASD");
    }
    private void loadTexture(GL4 gl, BufferedImage img){
        TextureData data = AWTTextureIO.newTextureData(gl.getGLProfile(), img, false);

        int texture = GLObject.createTextures(gl, GL_TEXTURE_2D, 1)[0];
        gl.glTextureStorage2D(texture, 1, GL_RGBA8, data.getWidth(), data.getHeight());
        data.getBuffer();
        gl.glTextureSubImage2D(texture,0,
                0,0,
                data.getWidth(),data.getHeight(),
                data.getPixelFormat(),data.getPixelType(),
                data.getBuffer());

        gl.glTextureParameteri(texture,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        gl.glTextureParameteri(texture,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        gl.glTextureParameteri(texture,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
        gl.glTextureParameteri(texture,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);

        gl.glBindTextureUnit(0,texture);
    }
    public void generateBitmap(GL4 gl, String filepath, int fontSize) {
        CInfo[] cInfos = new CInfo[asciiEnd - asciiStart];
        Font font = new Font(filepath, Font.BOLD, fontSize);

        // Create fake image to get font information
        BufferedImage img = new BufferedImage(1, 1, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g2d = img.createGraphics();
        g2d.setFont(font);
        FontMetrics fontMetrics = g2d.getFontMetrics();

        int estimatedWidth = (int)Math.sqrt(256) * font.getSize() + 1;
        final int lineHeight = fontMetrics.getHeight();
        int width = 0;
        int height = lineHeight;
        int x = 0;

        for(char i = asciiStart; i < asciiEnd; ++i) {
            if (font.canDisplay(i)) {
                fontMetrics.getLeading();
                CInfo charInfo = new CInfo(x, height-lineHeight, fontMetrics.charWidth(i), fontMetrics.getHeight());
                cInfos[i - asciiStart] = charInfo;
                width = Math.max(x + charInfo.width, width);

                x += charInfo.width * 1.3;
                if (x > estimatedWidth) {
                    x = 0;
                    height += lineHeight;
                }
            } else {
                CInfo charInfo = new CInfo(x, height-lineHeight, fontMetrics.charWidth(35), fontMetrics.getHeight());
                cInfos[i - asciiStart] = charInfo;
            }
        }
        g2d.dispose();

        // Create the real texture
        img = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        g2d = img.createGraphics();
        g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g2d.setFont(font);
        g2d.setColor(Color.WHITE);
        for (char i = asciiStart; i < asciiEnd; ++i) {
            if (font.canDisplay(i)) {
                CInfo info = cInfos[i - asciiStart];
                info.calculateTextureCoordinates(width, height);
                g2d.drawString("" + i, info.sourceX, info.sourceY+fontSize);
            }
        }
        g2d.dispose();

        charInfos = new CharacterInfo[asciiEnd - asciiStart];
        for (int i = asciiStart; i < asciiEnd; ++i) {
            charInfos[i - asciiStart] = new CharacterInfo((char)i, cInfos[i - asciiStart]);
        }
        loadTexture(gl,img);
    }
}
/*
public class FontMap {
    private static final String usable = " ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    private static final char[] usableC = usable.toCharArray();
    HashMap<Character, CharacterInfo> charInfoMap;
    public FontMap(GL4 gl) {
        generateBitmap(gl,"C:/Windows/Fonts/Arial.ttf", 24);
    }
    public List<Letter> createLabel(String text) {
        List<Letter> letters = new ArrayList<>(text.length());

        int pixelX = 0;

        char[] chars = text.toCharArray();
        for (char aChar : chars) {
            CharacterInfo charInfo = charInfoMap.get(aChar);
            if(charInfo.id != ' ')letters.add(new Letter(charInfo, pixelX));
            pixelX += charInfo.width;
        }
        return letters;
        //return new gLabel(x,y,letters,"ASD");
    }
    private void loadTexture(GL4 gl, BufferedImage img){
        TextureData data = AWTTextureIO.newTextureData(gl.getGLProfile(), img, false);

        int texture = GLObject.createTextures(gl, GL_TEXTURE_2D, 1)[0];
        gl.glTextureStorage2D(texture, 1, GL_RGBA8, data.getWidth(), data.getHeight());
        data.getBuffer();
        gl.glTextureSubImage2D(texture,0,
                0,0,
                data.getWidth(),data.getHeight(),
                data.getPixelFormat(),data.getPixelType(),
                data.getBuffer());

        gl.glTextureParameteri(texture,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
        gl.glTextureParameteri(texture,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
        gl.glTextureParameteri(texture,GL_TEXTURE_WRAP_S,GL_CLAMP_TO_EDGE);
        gl.glTextureParameteri(texture,GL_TEXTURE_WRAP_T,GL_CLAMP_TO_EDGE);

        gl.glBindTextureUnit(0,texture);
    }
    public void generateBitmap(GL4 gl, String filepath, int fontSize) {
        HashMap<Character, CInfo> CInfoMap = new HashMap<>(usable.length());
        Font font = new Font(filepath, Font.BOLD, fontSize);

        // Create fake image to get font information
        BufferedImage img = new BufferedImage(1, 1, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g2d = img.createGraphics();
        g2d.setFont(font);
        FontMetrics fontMetrics = g2d.getFontMetrics();

        int estimatedWidth = (int)Math.sqrt(usable.length()) * font.getSize() + 1;
        final int lineHeight = fontMetrics.getHeight();
        int width = 0;
        int height = lineHeight;
        int x = 0;

        for (char c:usableC) {
            if (font.canDisplay(c)) {
                fontMetrics.getLeading();
                CInfo charInfo = new CInfo(x, height-lineHeight, fontMetrics.charWidth(c), fontMetrics.getHeight());
                CInfoMap.put(c, charInfo);
                width = Math.max(x + charInfo.width, width);

                x += charInfo.width * 1.3;
                if (x > estimatedWidth) {
                    x = 0;
                    height += lineHeight;
                }
            }
        }
        g2d.dispose();

        // Create the real texture
        img = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        g2d = img.createGraphics();
        g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g2d.setFont(font);
        g2d.setColor(Color.WHITE);
        for (char c:usableC) {
            if (font.canDisplay(c)) {
                CInfo info = CInfoMap.get(c);
                info.calculateTextureCoordinates(width, height);
                g2d.drawString("" + c, info.sourceX, info.sourceY+fontSize);
            }
        }
        g2d.dispose();

        charInfoMap = new HashMap<>(usable.length());
        CInfoMap.forEach((k, v)-> {
            charInfoMap.put(k, new CharacterInfo(k, v));
        });
        loadTexture(gl,img);
    }
}*/
