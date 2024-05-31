#version 460

layout(location=0) in vec2 tex_coord;

layout(location=0) out vec4 color;
layout(location=1) out int id;

layout(binding=0) uniform sampler2D tex;

void main() {
    color = texture(tex,tex_coord.xy);
    id = -1;
}