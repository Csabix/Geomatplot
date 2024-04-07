#version 460

struct Line {
    vec4 c;
    vec2 p;
    float l;
    float padding;
};

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
    vec2 wh;
};

layout(std430, binding = 1) readonly buffer skeleton {
    Line[] lines;
};

//uniform float w = 640f;
const float width = 60.0f;

layout(location=0) out vec4 color;
layout(location=1) out float dist;
layout(location=2) out float len;

/*const int map[6] = {2,3,4,
                    4,3,5};*/
const int map[6] = {2,3,4,
                    4,5,3};

void main() {
    //int i = gl_VertexID % 6;
    int i = (map[gl_VertexID % 6] + (gl_VertexID / 6) * 2) / 2;
    vec2 position = lines[i].p; // Current Line position

    vec2 a = normalize((lines[i-1].p - position));
    vec2 b = normalize((lines[i+1].p - position));
    float x = (width) / ((sqrt( (1.0 - dot(a,b)) / 2.0))); // Smaller the angle the more we need to offset

    a = vec2(-a.y,a.x);
    b = vec2(b.y,-b.x);

    vec2 v = (x * normalize((a + b)) / scale / wh );

    if (map[gl_VertexID % 6] % 2 == 1) v = -v;
    float tmp = dot(v,normalize((lines[i+1].p - position)));
    if(gl_VertexID % 6 < 2  || gl_VertexID % 6 > 4)tmp = -tmp;
    len = ( lines[i].l + tmp ) * scale.y;
    vec2 p = position - v;

    gl_Position = vec4((p - translate) * scale,0.1,1.0);

    color = lines[i].c;
    dist = map[gl_VertexID % 6] % 2 == 1 ? -1.0f : 1.0f;

    //if (gl_VertexID % 2 == 1) v = -v;
    //len = ( lines[i].l - dot(v,normalize((lines[i+1].p - position))) ) * scale.y;
    //len = lines[i].l * scale.y;
}


/*void main() {
    int i = gl_VertexID / 2; // Current Line point
    vec2 position = lines[i].p; // Current Line position

    vec2 a = normalize((lines[i-1].p - position));
    vec2 b = normalize((lines[i+1].p - position));
    float x = (width) / ((sqrt( (1.0 - dot(a,b)) / 2.0))); // Smaller the angle the more we need to offset

    a = vec2(-a.y,a.x);
    b = vec2(b.y,-b.x);

    vec2 v = (x * normalize((a + b)) / scale / wh );

    float tmp = dot(v,normalize((lines[i+1].p - position)));
    if (gl_VertexID % 3 == 0) tmp = -tmp;
    len = ( lines[i].l + tmp ) * scale.y;
    if (gl_VertexID % 2 == 1) v = -v;

    vec2 p = position - v;

    gl_Position = vec4((p - translate) * scale,0.1,1.0);

    color = lines[i].c;
    dist = gl_VertexID % 2 == 1 ? -1.0f : 1.0f;

    //if (gl_VertexID % 2 == 1) v = -v;
    //len = ( lines[i].l - dot(v,normalize((lines[i+1].p - position))) ) * scale.y;
    //len = lines[i].l * scale.y;
}*/

/*void main() {
    //float zoom = 2.0 / scale.y;
    //float aspect = 2.0 / scale.x / zoom;
    float aspect = wh.x / wh.y;

    int i = gl_VertexID / 2;

    vec2 position = lines[i].p;

    vec2 a = normalize((lines[i-1].p - position));
    vec2 b = normalize((lines[i+1].p - position));
    float x = (width) / ((sqrt( (1.0 - dot(a,b)) / 2.0)));

    a = vec2(-a.y,a.x);
    b = vec2(b.y,-b.x);

    vec2 v = (x * normalize((a + b)) / scale / wh );
    if (gl_VertexID % 2 == 1) v = -v;

    vec2 p = position - v;

    gl_Position = vec4((p - translate) * scale,0.1,1.0);

    color = lines[i].c;
    dist = gl_VertexID % 2 == 1 ? -1.0f : 1.0f;
    len = lines[i].l * scale.y;

    //len = lines[i].l * scale.y + asd;
}*/

/*
#version 460

struct Line {
    vec4 c;
    vec2 p;
    vec2 padding;
};

layout(std140, binding = 0) uniform Camera {
    vec2 scale;
    vec2 translate;
};

layout(std430, binding = 1) readonly buffer skeleton {
    Line[] lines;
};

layout(location=0) out vec4 color;
layout(location=1) out float dist;

const float width = 0.02f;// Half width

void main() {
    int i = gl_VertexID / 2;
    vec2 position = lines[i].p;
    vec2 v;
    if (i == 0) {
        //BEGIN
        v = lines[1].p - lines[0].p;
        v = vec2(v.y,-v.x);
        v *= width / length(v);
    } else if (i == lines.length() - 1) {
        //END
        v = lines[i].p - lines[i-1].p;
        v = vec2(v.y,-v.x);
        v *= width / length(v);
    } else {
        //MID
        vec2 a = normalize(lines[i-1].p - lines[i].p);
        vec2 b = normalize(lines[i+1].p - lines[i].p);
        float x = width / ((sqrt( (1.0 - dot(a,b)) / 2.0)));
        a = vec2(-a.y,a.x);
        b = vec2(b.y,-b.x);
        vec2 c = normalize(a + b);
        v = x * c;
    }
    //v *= 0.01f / length(v);
    if (gl_VertexID % 2 == 1) v = -v;
    gl_Position = vec4((position - translate) * scale - v,0.1,1.0);
    color = lines[i].c;
    dist = gl_VertexID % 2 == 1 ? -1.0f : 1.0f;
}*/
