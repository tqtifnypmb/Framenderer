#version 300 es

in vec4 vPosition;

void main() {
    vec3 W = vec3(0.2126, 0.7152, 0.0722);
    float brightness = dot(vPosition.rgb, W);
    gl_Position = vec4(-1.0 + brightness * 0.078125, 0.0, 0.0, 1.0);
    gl_PointSize = 1.0;
}
