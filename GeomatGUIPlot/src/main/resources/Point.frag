#version 460
const float bP = 0.2;

layout(location=0) in flat vec3 primaryColor_in;
layout(location=1) in flat int id_in;
layout(location=2) in flat int type_in;

layout(location=0) out vec4 color_out;
layout(location=1) out int id_out;

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
	float d;
	switch(type_in){
		case 0:
			d = circleSDF(p);
			break;
		case 1:
			d = sdStar5(p,1.0,0.5);
			break;
	}
	if (d > 0.0) discard;

	float o = 1.0 / (-bP) * (d + bP);
	vec3 color = mix(vec3(0,0,0), primaryColor_in, o);
	float alpha = mix( 1.0, 0.0,-o);

	color_out = vec4(color,alpha);
	id_out = id_in;
}