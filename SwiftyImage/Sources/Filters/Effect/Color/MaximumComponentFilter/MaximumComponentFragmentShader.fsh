#version 300 es

precision mediump float;

in vec2 fTextCoor;
uniform sampler2D firstInput;
out vec4 color;

void main() {
    vec4 tmp = texture(firstInput, fTextCoor);
    float v = max(max(tmp.r, tmp.g), tmp.b);
    color = vec4(v, v, v, tmp.a);
}
