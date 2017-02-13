#version 300 es

in vec4 vPosition;
in vec2 vTextCoor;
out vec2 fTextCoor;

void main() {
    gl_Position = vPosition;
    fTextCoor = vTextCoor;
}
