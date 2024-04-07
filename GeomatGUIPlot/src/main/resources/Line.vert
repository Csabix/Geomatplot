#version 460

struct Line {
    vec4 c;
    vec2 p;
    float l;
    float type; // 0 line, 10 dashed
};

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

layout(std430, binding = 1) readonly buffer skeleton {
    Line[] lines;
};

const float width = 20.0f;

layout(location=0) out vec4 color;
layout(location=1) out float dist;
layout(location=2) out float len;
layout(location=3) out float type;

const int map[6] = {2,3,4,
                    4,5,3};

void main() {
    int mapIndex = map[gl_VertexID % 6];
    int i = (mapIndex + (gl_VertexID / 6) * 2) / 2;

    vec2 position = lines[i].p; // Current Line position

    vec2 a = normalize((lines[i-1].p - position));
    vec2 b = normalize((lines[i+1].p - position));
    float x = width / sqrt((1.0 - dot(a,b)) / 2.0); // Smaller the angle the more we need to offset

    a = vec2(-a.y,a.x);
    if(dot(a,b) < 0.985) {
        b = vec2(b.y,-b.x);
    } else {
        x = width;
        b = vec2(0);
    }

    vec2 v = (x * normalize((a + b)) / scale / wh );
    if (mapIndex % 2 == 1) v = -v;

    float lenOffset = dot(v,normalize((lines[i+1].p - position)));
    if(gl_VertexID % 6 < 2  || gl_VertexID % 6 > 4)lenOffset = -lenOffset;
    len = ( lines[i].l + lenOffset ) * scale.y;

    gl_Position = vec4((position - v - translate) * scale,0.1,1.0);

    color = lines[i].c;
    type = lines[i].type;
    dist = mapIndex % 2 == 1 ? -1.0f : 1.0f;
}