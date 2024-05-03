#version 430

const vec2 positions[6] = vec2[6](
    vec2(-1, -1),
    vec2( 1, -1),
    vec2(-1,  1),

    vec2(-1,  1),
    vec2( 1, -1),
    vec2( 1,  1)
);

const vec2 uvs[6] = vec2[6](
    vec2( 0, 0),
    vec2( 1, 0),
    vec2( 0, 1),

    vec2( 0,  1),
    vec2( 1,  0),
    vec2( 1,  1)
);

layout(location = 0) out vec2 uv;

void main() {
    gl_Position = vec4(positions[gl_VertexID], 0, 1.0);
    uv = uvs[gl_VertexID];
}
