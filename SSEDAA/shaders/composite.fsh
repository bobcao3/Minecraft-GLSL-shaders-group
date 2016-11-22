#version 130

const bool colortex0MipmapEnabled = true;

uniform sampler2D depthtex1;
uniform sampler2D gcolor;
uniform float viewWidth;
uniform float viewHeight;
uniform float near;
uniform float far;

in vec4 texcoord;

ivec2 px = ivec2(texcoord.st * vec2(viewWidth, viewHeight));

bool detect_edge(in ivec2 ifpx) {
	float depth0 = texelFetch(depthtex1, ifpx, 0).r;
	float depth1 = texelFetchOffset(depthtex1, ifpx, 0, ivec2(0,1)).r * 0.9 + texelFetchOffset(depthtex1, ifpx, 0, ivec2(0,2)).r * 0.1;
	float depth2 = texelFetchOffset(depthtex1, ifpx, 0, ivec2(0,-1)).r * 0.9 + texelFetchOffset(depthtex1, ifpx, 0, ivec2(0,-2)).r * 0.1;
	float depth3 = texelFetchOffset(depthtex1, ifpx, 0, ivec2(1,0)).r * 0.9 + texelFetchOffset(depthtex1, ifpx, 0, ivec2(2,0)).r * 0.1;
	float depth4 = texelFetchOffset(depthtex1, ifpx, 0, ivec2(-1,0)).r * 0.9 + texelFetchOffset(depthtex1, ifpx, 0, ivec2(-2,0)).r * 0.1;

	float edge0 = 0.0;
	edge0 += float(depth0 > depth1);
	edge0 -= float(depth0 < depth1);
	float edge1 = 0.0;
	edge1 += float(depth0 > depth2);
	edge1 -= float(depth0 < depth2);
	float edge2 = 0.0;
	edge2 += float(depth0 > depth3);
	edge2 -= float(depth0 < depth3);
	float edge3 = 0.0;
	edge3 += float(depth0 > depth4);
	edge3 -= float(depth0 < depth4);

	bool isedge = abs(edge0 + edge1 + edge2 + edge3) > 1.43;

	return isedge;
}

void main() {
	vec4 orgcolor = texelFetch(gcolor, px, 0);
	bool edge0 = detect_edge(px);
	bool edge1 = detect_edge(px + ivec2(1,0));
	bool edge2 = detect_edge(px + ivec2(-1,0));
	bool edge3 = detect_edge(px + ivec2(0,1));
	bool edge4 = detect_edge(px + ivec2(0,-1));

	vec4 color = orgcolor;
	if (edge1 && edge3) {
		color = mix(color, texelFetchOffset(gcolor, px, 0, ivec2(0,1)), 0.2);
		color = mix(color, texelFetchOffset(gcolor, px, 0, ivec2(1,0)), 0.2);
	}
	if (edge2 && edge4) {
		color = mix(color, texelFetchOffset(gcolor, px, 0, ivec2(0,-1)), 0.2);
		color = mix(color, texelFetchOffset(gcolor, px, 0, ivec2(-1,0)), 0.2);
	}
	if (edge1 && edge4) {
		color = mix(color, texelFetchOffset(gcolor, px, 0, ivec2(0,-1)), 0.2);
		color = mix(color, texelFetchOffset(gcolor, px, 0, ivec2(1,0)), 0.2);
	}
	if (edge2 && edge3) {
		color = mix(color, texelFetchOffset(gcolor, px, 0, ivec2(0,1)), 0.2);
		color = mix(color, texelFetchOffset(gcolor, px, 0, ivec2(-1,0)), 0.2);
	}
	if (edge0) {
		color = mix(color, texelFetchOffset(gcolor, px, 0, ivec2(0,1)), 0.1);
		color = mix(color, texelFetchOffset(gcolor, px, 0, ivec2(0,-1)), 0.2);
		color = mix(color, texelFetchOffset(gcolor, px, 0, ivec2(1,0)), 0.2);
		color = mix(color, texelFetchOffset(gcolor, px, 0, ivec2(-1,0)), 0.2);
	}

	if (edge0) {
		color = mix(color, texture(gcolor, texcoord.st, 2.0), 0.4);
	}

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color;
}
