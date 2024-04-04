#version 460

layout(location=0) in vec2 anchor;
layout(location=1) in vec2 offset;
layout(location=2) in vec2 tex_coord;

layout(location=0) out vec2 tex_coord_out;

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

void main(){
    gl_Position = vec4((anchor - translate) * scale + offset.xy * 2.0 / wh,0,1);
    tex_coord_out = tex_coord;
}