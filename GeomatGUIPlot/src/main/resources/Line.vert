#version 460

struct Line {
    vec4 primaryColorWidth;
    vec2 position;
    float len;
// float padding;
};

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

layout(std430, binding = 1) readonly buffer skeleton {
    Line[] lines;
};

layout(location=0) out vec3 primaryColor_out;
layout(location=1) out float sideDistance_out;
layout(location=2) out float lineLength_out;
layout(location=3) out int id_out;

uniform int drawerID;

const int map[6] = {2,3,4,
                    5,4,3};

void main() {
    int mapIndex = map[gl_VertexID % 6];
    int i = gl_VertexID / 6 + mapIndex / 2;

    vec2 position = lines[i].position; // Current Line position

    vec2 positionPrev = lines[i-1].position;
    vec2 positionNext = lines[i+1].position;

    if(any(isnan(positionPrev)) || any(isinf(positionPrev))) {
        positionPrev = position + position - positionNext;
    }
    if(any(isnan(positionNext)) || any(isinf(positionNext))) {
        positionNext = position + position - positionPrev;
    }

    vec2 a = normalize((positionPrev - position));
    vec2 b = normalize((positionNext - position));
    float x = lines[i].primaryColorWidth.w * inversesqrt((1.0 - dot(a,b)) / 2.0); // Smaller the angle the more we need to offset
    x = min(x, 8 * lines[i].primaryColorWidth.w);

    a = vec2(-a.y,a.x);
    b = vec2(b.y,-b.x);

    vec2 v = (x * normalize(a + b) / scale / wh );
    if (mapIndex % 2 == 1) v = -v;

    float lenOffset = dot(v,vec2(-b.y,b.x));
    if(gl_VertexID % 6 < 2  || gl_VertexID % 6 > 4) lenOffset = -lenOffset;

    gl_Position = vec4((position - v - translate) * scale,0.1,1.0);

    lineLength_out = isnan(lines[i].len) ? 0.0f : ( lines[i].len + lenOffset ) * (scale.y * 10000.0f);
    primaryColor_out = lines[i].primaryColorWidth.xyz;
    sideDistance_out = mapIndex % 2 == 1 ? -1.0f : 1.0f;
    id_out = gl_DrawID | drawerID;
}