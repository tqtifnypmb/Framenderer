#version 300 es

in vec4 vPosition;

void main() {
    float brightness = dot(vPosition.rgb, vec3(0.2126, 0.7152, 0.0722));
    gl_Position = vec4(-1.0 + brightness * 0.0078125, 0.0, 0.0, 1.0);
    gl_PointSize = 1.0;
}
