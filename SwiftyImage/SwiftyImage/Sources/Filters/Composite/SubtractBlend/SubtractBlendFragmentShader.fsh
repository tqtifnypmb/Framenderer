#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform sampler2D secondInput;
uniform bool isSubtractor;

out vec4 color;

void main() {
    vec4 base = texture(secondInput, fTextCoor);
    vec4 top = texture(firstInput, fTextCoor);
    
    if (isSubtractor) {
        color = vec4(top.rgb - base.rgb, 1.0);
    } else {
        color = vec4(base.rgb - top.rgb, 1.0);
    }
}

