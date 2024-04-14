#version 460

struct Letter {
    vec4 offset; // x,y,w,h
    vec4  tex_coord; // u,v,w,h
    vec2 anchor;
    vec2 padding;
};

layout(location=0) out vec2 tex_coord_out;

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

layout(std430, binding = 2) readonly buffer lettersBuffer {
    Letter[] letters;
};
const vec2[] operations = { vec2(0, 0), vec2(0,-1), vec2(1,-1),
                            vec2(1,-1), vec2(1, 0), vec2(0, 0), };
void main(){
    Letter c = letters[gl_VertexID / 6];
    vec2 operation = operations[gl_VertexID % 6];
    vec2 p = (c.anchor - translate) * scale;
    vec2 o = vec2(c.offset.x + operation.x * c.offset.z, c.offset.y + operation.y * c.offset.w) * 2.0 / wh;
    gl_Position = vec4(p + o,0,1);
    tex_coord_out = vec2(c.tex_coord.x + operation.x * c.tex_coord.z, c.tex_coord.y - operation.y * c.tex_coord.w);;
}
/*
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
}*/
