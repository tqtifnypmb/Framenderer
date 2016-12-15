#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform sampler2D secondInput;

out vec4 color;

void main() {
    vec4 base = texture(secondInput, fTextCoor);
    vec4 top = texture(firstInput, fTextCoor);
    
    color = clamp(base / (vec4(1.0) - top), vec4(0.0), vec4(1.0));
}

