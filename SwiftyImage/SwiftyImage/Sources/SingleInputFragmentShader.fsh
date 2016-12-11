#version 300 es

precision mediump float;

in vec2 fTextCoor;
uniform sampler2D firstInput;
out vec4 color;

void main() {
    color = texture(firstInput, fTextCoor);
}
