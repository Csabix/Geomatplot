#version 430

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

layout(location = 1) uniform float x;
layout(location = 2) uniform float y;
layout(location = 3) uniform float w;
layout(location = 4) uniform float h;
layout(location = 5) uniform int flip  = 1;

const ivec2 uvs[6] = ivec2[6](
ivec2( 0, 0),
ivec2( 0, 1),
ivec2( 1, 0),

ivec2( 0,  1),
ivec2( 1,  1),
ivec2( 1,  0)
);

layout(location=0) out vec2 uv_out;

void main() {
    vec2 uv = vec2(uvs[gl_VertexID]);
    vec2 position = vec2(x,y);
    position.x += uv.x * w;
    position.y -= uv.y * h;

    if(flip != 0) uv.y = float(uvs[gl_VertexID].y ^ 1);

    uv_out = uv;
    gl_Position = vec4((position - translate) * scale,0,1);
}
