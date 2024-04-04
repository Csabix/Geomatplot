#version 460

layout(location=0) in vec2 pos;
layout(location=1) in vec3 col;
layout(location=2) in vec3 bcol;

layout(location=0) out vec3 color;
layout(location=1) out vec3 bcolor;
layout(location=2) out int id;

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

void main(){
    gl_Position = vec4((pos - translate) * scale,0,1);
	gl_PointSize = 20.;
	color = col;
	bcolor = bcol;
    id = gl_VertexID;
}