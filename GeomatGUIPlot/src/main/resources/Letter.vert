#version 460

struct Letter {
    vec4 offset; // x,y,w,h
    vec4 tex_coord; // u,v,w,h
    vec2 anchor;
    vec2 padding; // Not used
};

layout(location=0) out vec2 tex_coord_out;

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

layout(std430, binding = 1) readonly buffer lettersBuffer {
    Letter[] letters;
};
const vec2[] operations = { vec2(0, 0), vec2(0,-1), vec2(1,-1),
                            vec2(1,-1), vec2(1, 0), vec2(0, 0), };
void main(){
    Letter c = letters[gl_VertexID / 6];
    vec2 operation = operations[gl_VertexID % 6];
    vec2 position = (c.anchor - translate) * scale;
    vec2 offset = vec2(c.offset.x + operation.x * c.offset.z, c.offset.y + operation.y * c.offset.w) * 2.0 / wh;
    gl_Position = vec4(position + offset,0,1);
    tex_coord_out = vec2(c.tex_coord.x + operation.x * c.tex_coord.z, c.tex_coord.y - operation.y * c.tex_coord.w);;
}