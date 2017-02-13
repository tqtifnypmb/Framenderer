#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform sampler2D secondInput;
uniform sampler2D thirdInput;

out vec4 color;

void main() {
    vec4 top = texture(secondInput, fTextCoor);
    vec4 bottom = texture(firstInput, fTextCoor);
    vec4 mask = texture(thirdInput, fTextCoor);
    
    if (mask.a == 0.0) {
        color = bottom;
    } else {
        color = top;
    }
}
