#version 460

layout(location=0) in vec4 col;
layout(location=1) in vec2 pos;

layout(location=0) out vec4 color;
layout(location=1) out int id;

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

void main() {
    gl_Position = vec4((pos - translate) * scale,0,1);
    color = col;
    id = gl_DrawID;
}