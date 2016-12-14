#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform vec2 center;
uniform float size;
uniform float texelWidth;
uniform float texelHeight;

out vec4 color;

void main() {
    vec2 ratio = fTextCoor - center;
    float xUnit = size / 100.0;
    float yUnit = size / 100.0;
    //vec2 offset = vec2(ratio.x * xUnit, ratio.y * yUnit);
    
    vec2 offset = 1.0/100.0 * (fTextCoor - center) * size;
    vec4 acc = vec4(0);
    acc += texture(firstInput, fTextCoor) * 0.1111111;
    acc += texture(firstInput, fTextCoor + offset) * 0.1111111;
    acc += texture(firstInput, fTextCoor + offset * 2.0) * 0.1111111;
    acc += texture(firstInput, fTextCoor + offset * 3.0) * 0.1111111;
    acc += texture(firstInput, fTextCoor + offset * 4.0) * 0.1111111;
    acc += texture(firstInput, fTextCoor - offset) * 0.1111111;
    acc += texture(firstInput, fTextCoor - offset * 2.0) * 0.1111111;
    acc += texture(firstInput, fTextCoor - offset * 3.0) * 0.1111111;
    acc += texture(firstInput, fTextCoor - offset * 4.0) * 0.1111111;
    color = acc;
}
