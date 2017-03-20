#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform float ev;

out vec4 color;

void main() {
    vec4 tmp = texture(firstInput, fTextCoor);
    color = vec4(clamp(tmp.rgb * vec3(ev), vec3(0.0), vec3(1.0)), 1.0);
}
