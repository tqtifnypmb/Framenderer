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
    
    vec4 zero = vec4(0.0);
    if (mask == zero) {
        color = bottom;
    } else {
        color = top;
    }
}
