#version 460

layout(location=0) in vec3 primaryColor_in;
layout(location=1) in float sideDistance_in;
layout(location=2) in float lineLength_in;
layout(location=4) in flat int id_in;

layout(location=0) out vec4 color_out;
layout(location=1) out int id_out;

void main() {
    float alphaSide = 1.3 - abs(sideDistance_in);
    float alphaLenght = float(abs(0.5 - fract(lineLength_in * 10.0)) / 0.3 - 0.2);

    color_out = vec4(primaryColor_in,min(alphaSide, alphaLenght));
    id_out = id_in;
}