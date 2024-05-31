#version 430

layout(location = 0) in vec2 uv;

layout(location = 0) uniform sampler2D tex;

layout(location = 0) out vec4 color;
layout(location = 1) out int id;

void main() {
    color = texture(tex,uv);
    id = -1;
}
