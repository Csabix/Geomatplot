#version 460

layout(location=0) in vec2 position_in;
layout(location=1) in vec3 primaryColor_in;
layout(location=2) in float size_in;
layout(location=3) in float type_in;

layout(location=0) out vec3 primaryColor_out;
layout(location=1) out int id_out;
layout(location=2) out int type_out;

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

uniform int drawerID;

void main(){
    primaryColor_out = primaryColor_in;
    type_out = int(type_in);
    id_out = gl_VertexID | drawerID;

    gl_PointSize = size_in;
    gl_Position = vec4((position_in - translate) * scale,0,1);
}