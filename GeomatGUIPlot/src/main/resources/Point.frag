#version 460

/*layout(location=0) in flat vec3 color_in;
layout(location=1) in flat vec3 bcolor;
layout(location=2) in flat int id_in;
layout(location=0) out vec4 color;
layout(location=1) out int ID;

float circleSDF(vec2 position){
    return length(position) - 0.85;
}

void main(){
	vec2 p = (gl_PointCoord * 2. - 1.);
	float d = circleSDF(p);
	vec3 col = mix(bcolor, color_in, smoothstep(0.001,.0024,abs(d*0.015)));
	float alpha = mix( 1.0, 0.0,smoothstep(0.001,.0024,d*0.015) );
	color = vec4(col,alpha);
	ID = d < 0.0 ? id_in : -1;
}*/

layout(location=0) in flat vec3 color_in;
layout(location=1) in flat vec3 bcolor;
layout(location=2) in flat int id_in;

layout(location=0) out vec4 color;
layout(location=1) out int id;

const float bP = 0.2;
uniform int drawerID;

float circleSDF(vec2 position){
	return length(position) - 1.0;
}

float sdStar5(in vec2 p, in float r, in float rf)
{
	const vec2 k1 = vec2(0.809016994375, -0.587785252292);
	const vec2 k2 = vec2(-k1.x,k1.y);
	p.x = abs(p.x);
	p -= 2.0*max(dot(k1,p),0.0)*k1;
	p -= 2.0*max(dot(k2,p),0.0)*k2;
	p.x = abs(p.x);
	p.y -= r;
	vec2 ba = rf*vec2(-k1.y,k1.x) - vec2(0,1);
	float h = clamp( dot(p,ba)/dot(ba,ba), 0.0, r );
	return length(p-ba*h) * sign(p.y*ba.x-p.x*ba.y);
}

void main(){
	vec2 p = (gl_PointCoord * 2. - 1.);
	float d = circleSDF(p);
	//float d = sdStar5(p,1.0,0.5);
	if (d > 0.0) discard;
	float o = 1.0 / (-bP) * (d + bP);

	vec3 col = mix(bcolor, color_in, o);
	float alpha = mix( 1.0, 0.0,-o);
	color = vec4(col,alpha);
	id = d < 0.0 ? id_in | drawerID : -1;
}