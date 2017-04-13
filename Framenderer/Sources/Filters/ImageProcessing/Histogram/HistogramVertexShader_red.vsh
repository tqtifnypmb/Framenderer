#version 300 es

in vec4 vPosition;

void main() {
    gl_Position = vec4(-1.0 + vPosition.r * 0.0078125, 0.0, 0.0, 1.0);
    gl_PointSize = 1.0;
}
