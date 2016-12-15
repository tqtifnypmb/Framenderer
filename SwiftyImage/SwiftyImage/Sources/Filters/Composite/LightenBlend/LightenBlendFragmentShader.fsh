#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform sampler2D secondInput;

out vec4 color;

void main() {
    vec4 base = texture(secondInput, fTextCoor);
    vec4 top = texture(firstInput, fTextCoor);
    
    color = vec4(max(top.rgb * base.a, base.rgb * top.a) + top.rgb * (1.0 - base.a) + base.rgb * (1.0 - top.a), 1.0);
}

