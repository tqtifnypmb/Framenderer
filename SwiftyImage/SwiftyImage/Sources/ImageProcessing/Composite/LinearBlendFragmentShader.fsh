#version 300 es

precision highp float;

in vec2 fTextCoor;
uniform sampler2D firstInput;
uniform sampler2D secondInput;
uniform float a;

out vec4 color;

void main() {
    vec3 blendColor = texture(firstInput, fTextCoor).rgb * (1.0 - a) + texture(secondInput, fTextCoor).rgb * a;
    color = vec4(blendColor, 1.0);
}
