#version 460

layout(location=0) in vec2 pos;
//layout(location=1) in vec4 col;

layout(location=0) out vec4 color;

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

void main() {
    gl_Position = vec4((pos - translate) * scale,0,1);
    //color = col;
    color = vec4(0,1,0,0.9);
}
