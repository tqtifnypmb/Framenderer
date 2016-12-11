#version 300 es

in vec4 vPosition;
in vec2 vTextCoor;

uniform float xOffset;
uniform float yOffset;

out vec2 fTextCoor[TEXTCOOR_COUNT];

void main() {
    gl_Position = vPosition;
    fTextCoor = vTextCoor;
}
