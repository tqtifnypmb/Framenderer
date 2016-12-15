#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform vec4 minColor;
uniform vec4 maxColor;

out vec4 color;

void main() {
    vec4 tmp = texture(firstInput, fTextCoor);
    color = clamp(minColor, maxColor);
}
