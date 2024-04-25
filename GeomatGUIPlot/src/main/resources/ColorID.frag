#version 460

layout(location=0) in vec4 color_in;
layout(location=1) in flat int id_in;

layout(location=0) out vec4 color;
layout(location=1) out int id;

uniform int drawerID = 0;

void main() {
    color = color_in;
    id = id_in | drawerID;
}