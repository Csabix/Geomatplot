#version 430

const vec2 positions[6] = vec2[6](
    vec2(-1, -1),
    vec2( 1, -1),
    vec2(-1,  1),

    vec2(-1,  1),
    vec2( 1, -1),
    vec2( 1,  1)
);

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

uniform float depth = 1;

layout(location=0) out vec2 vs_out_position;

void main()
{
    vs_out_position = positions[gl_VertexID] / scale + translate;
    gl_Position = vec4(positions[gl_VertexID],depth,1);
}
