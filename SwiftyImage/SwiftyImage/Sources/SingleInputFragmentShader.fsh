#version 300 es

precision mediump float;

in vec2 fTextCoor;
uniform sampler2D fSampler;
out vec4 color;

void main() {
    color = texture(fSampler, fTextCoor);
}
