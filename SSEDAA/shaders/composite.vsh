#version 130

out vec4 texcoord;

void main() {
	gl_Position = ftransform();
	texcoord = gl_MultiTexCoord0;
}
	