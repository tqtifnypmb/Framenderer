#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform vec4 bias;

out vec4 color;

void main() {
    color = clamp(bias + texture(firstInput, fTextCoor), vec4(0.0), vec4(1.0));
}
