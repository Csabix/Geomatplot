#version 460

layout(location=0) in vec4 color_in;
layout(location=1) in vec2 position_in;

layout(location=0) out vec4 color_out;
layout(location=1) out int id_out;

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

uniform int drawerID = 0;

void main() {
    gl_Position = vec4((position_in - translate) * scale,0,1);
    color_out = color_in;
    id_out = gl_DrawID | drawerID;
}