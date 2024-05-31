package GeomatPlot.Font;

import GeomatPlot.GLObject;
import com.jogamp.opengl.GL4;
import com.jogamp.opengl.util.texture.TextureData;
import com.jogamp.opengl.util.texture.awt.AWTTextureIO;

import java.awt.*;
import java.awt.image.BufferedImage;
import java.util.ArrayList;
import java.util.List;

import static com.jogamp.opengl.GL.*;

public class FontMap {
    private static final int asciiStart = 32;
    private static final int asciiEnd = 256;

    private Font font;
    public boolean newFont;
    public int texture;
    CharacterInfo[] charInfos;

    public FontMap(GL4 gl) {
        font = new Font(null, Font.BOLD, 24);
        generateBitmap(gl);
    }

    public void setFont(String path, boolean bold, boolean italic, int size) {
        int type = 0;
        if(bold) type = type | Font.BOLD;
        if(italic) type = type | Font.ITALIC;
        font = new Font(path, type, size);
        newFont = true;
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
    }

    private void loadTexture(GL4 gl, BufferedImage img){
        if(texture != 0) {
            GLObject.deleteTextures(gl, new int[]{texture});
            texture = 0;
        }

        TextureData data = AWTTextureIO.newTextureData(gl.getGLProfile(), img, false);

        texture = GLObject.createTextures(gl, GL_TEXTURE_2D, 1)[0];
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
    }

    public void generateBitmap(GL4 gl) {
        CInfo[] cInfos = new CInfo[asciiEnd - asciiStart];
        int fontSize = font.getSize();

        // Create fake image to get font information
        BufferedImage img = new BufferedImage(1, 1, BufferedImage.TYPE_INT_ARGB);
        Graphics2D g2d = img.createGraphics();
        g2d.setFont(font);
        FontMetrics fontMetrics = g2d.getFontMetrics();

        int estimatedWidth = ((int)Math.sqrt(256-32) + 1) * font.getSize();
        final int lineHeight = fontMetrics.getHeight();
        int width = 0;
        int height = lineHeight;
        int x = 0;

        int fontH = fontMetrics.getHeight();
        for(char i = asciiStart; i < asciiEnd; ++i) {
            if (font.canDisplay(i)) {
                CInfo charInfo = new CInfo(x, height-lineHeight, fontMetrics.charWidth(i), fontH);
                cInfos[i - asciiStart] = charInfo;
                width = Math.max(x + charInfo.width, width);

                x += charInfo.width * 1.3;
                if (x > estimatedWidth) {
                    x = 0;
                    height += lineHeight;
                }
            } else {
                CInfo charInfo = new CInfo(x, height-lineHeight, fontMetrics.charWidth(32), fontH);
                cInfos[i - asciiStart] = charInfo;
            }
        }
        g2d.dispose();

        // Create the real texture
        img = new BufferedImage(width, height, BufferedImage.TYPE_INT_ARGB);
        g2d = img.createGraphics();
        g2d.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g2d.setFont(font);
        g2d.setColor(Color.BLACK);
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

    public void clean(GL4 gl) {
        GLObject.deleteTextures(gl, new int[]{texture});
        charInfos = null;
    }
}
