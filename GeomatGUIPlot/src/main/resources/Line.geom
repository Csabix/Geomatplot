#version 460

layout(triangles) in;
layout(triangle_strip, max_vertices = 3) out;

layout(location=0) in vec4 color[];
layout(location=1) in float dist[];
layout(location=2) in float len[];

layout(location=0) out vec4 color_out;
layout(location=1) out float dist_out;
layout(location=2) out float len_out;

void main() {
    /*float[3] ds;

    if(abs(len[0] - len[1]) < 0.01) {
        ds[0] = 0;ds[1] = 0;ds[2] = 1;
    } else if (abs(len[0] - len[2]) < 0.01) {
        ds[0] = 0;ds[2] = 0;ds[1] = 1;
    } else {
        ds[1] = 0;ds[2] = 0;ds[0] = 1;
    }
    for(int i = 0; i < 3; ++i) {
        gl_Position = gl_in[i].gl_Position;
        color_out = color[i];
        dist_out = dist[i];
        len_out = ds[i];

        EmitVertex();
    }*/
    int a,b,c;
    if(len[0] == len[1]) {
        a = 0;b = 1;c = 2;
    } else if (len[0] == len[2]) {
        a = 0;b = 2;c = 1;
    } else {
        a = 1; b = 2; c = 0;
    }
    vec2 pa = gl_in[a].gl_Position.xy;
    vec2 pb = gl_in[b].gl_Position.xy;
    vec2 pc = gl_in[c].gl_Position.xy;

    vec2 pm = (pa + pb) / 2.0;
    float ac = length(pc - pa);
    float mc = length(pc - pm);
    float bc = length(pc - pb);
    float closer,further;
    gl_Position = gl_in[a].gl_Position;
    color_out = color[a];
    dist_out = dist[a];
    //len_out = 0 + 0.01 * dot(pa - pb,pc);
    len_out = len[a] + (len[a] - len[c]) * ac/mc;
    EmitVertex();

    gl_Position = gl_in[b].gl_Position;
    color_out = color[b];
    dist_out = dist[b];
    //len_out = 0 + 0.01 * dot(pb - pa,pc);
    len_out = len[a] + (len[a] - len[c]) * bc/mc;
    EmitVertex();

    gl_Position = gl_in[c].gl_Position;
    color_out = color[c];
    dist_out = dist[c];
    len_out = len[c];
    EmitVertex();
    /*gl_Position = gl_in[0].gl_Position;
    color_out = color[0];
    dist_out = 0;
    len_out = len[0];
    EmitVertex();

    gl_Position = gl_in[1].gl_Position;
    color_out = color[1];
    dist_out = 0;
    len_out = len[1];
    EmitVertex();

    gl_Position = gl_in[2].gl_Position;
    color_out = color[2];
    dist_out = 1;
    len_out = len[2];
    EmitVertex();*/

    /*for(int i = 0; i < 3; ++i) {
        gl_Position = gl_in[i].gl_Position;
        color_out = color[i];
        dist_out = dist[i];
        len_out = len[i];

        EmitVertex();
    }*/
    EndPrimitive();
}