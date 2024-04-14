#version 460

layout(location=0) in vec4 color_in;

layout(location=0) out vec4 color;
layout(location=1) out int id;

void main() {
    color = color_in;
    id = -1;
}
