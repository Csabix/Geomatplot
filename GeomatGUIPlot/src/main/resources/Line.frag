#version 460

layout(location=0) in vec4 color_in;
layout(location=1) in float dist;
layout(location=2) in float len;
layout(location=3) in float fractMult;
layout(location=4) in flat int id_in;

layout(location=0) out vec4 color;
layout(location=1) out int id;

uniform int drawerID;

void main() {
    float alpha = smoothstep( 0.0, 1.0, min( 1.1 - abs(dist), abs(0.5 - fract(len * fractMult)) / 0.3 - 0.2 ));
    color = vec4(color_in.rgb,color_in.a * alpha);
    id = id_in | drawerID;
}