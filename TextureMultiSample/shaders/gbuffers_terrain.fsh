#version 130

uniform int fogMode;
uniform sampler2D texture;
uniform sampler2D lightmap;

uniform ivec2 atlasSize;

in vec4 color;
in vec2 texcoord;
in vec2 lmcoord;
in vec2 normal;

vec4 texSmooth(in sampler2D s, in vec2 texc) {
	vec2 pix_size = vec2(1.0) / (vec2(atlasSize) * 24.0);

	ivec2 px0 = ivec2((texc + pix_size * vec2(0.1, 0.5)) * atlasSize);
	vec4 texel0 = texelFetch(s, px0, 0);
	ivec2 px1 = ivec2((texc + pix_size * vec2(0.5, -0.1)) * atlasSize);
	vec4 texel1 = texelFetch(s, px1, 0);
	ivec2 px2 = ivec2((texc + pix_size * vec2(-0.1, -0.5)) * atlasSize);
	vec4 texel2 = texelFetch(s, px2, 0);
	ivec2 px3 = ivec2((texc + pix_size * vec2(0.5, 0.1)) * atlasSize);
	vec4 texel3 = texelFetch(s, px3, 0);

	return (texel0 + texel1 + texel2 + texel3) * 0.25;
}

/* DRAWBUFFERS:02 */
void main() {
	gl_FragData[0] = texSmooth(texture, texcoord.st) * texture2D(lightmap, lmcoord.st) * color;
	if(fogMode == 9729)
		gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp((gl_Fog.end - gl_FogFragCoord) / (gl_Fog.end - gl_Fog.start), 0.0, 1.0));
	else if(fogMode == 2048)
		gl_FragData[0].rgb = mix(gl_Fog.color.rgb, gl_FragData[0].rgb, clamp(exp(-gl_FogFragCoord * gl_Fog.density), 0.0, 1.0));
}
