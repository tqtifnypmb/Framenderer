#version 300 es

precision mediump float;

in vec2 fTextCoor;
uniform sampler2D firstInput;
out vec4 color;

void main() {
    vec4 tmp = texture(firstInput, fTextCoor);
    color = vec4(vec3(1.0) - tmp.rgb, tmp.a);
}
