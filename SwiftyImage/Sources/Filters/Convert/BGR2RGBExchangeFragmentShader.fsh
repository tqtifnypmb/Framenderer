#version 300 es

precision mediump float;

in vec2 fTextCoor;
uniform sampler2D firstInput;
out vec4 color;

//bgr -> rgb
void main() {
    vec4 tmp = texture(firstInput, fTextCoor);
    color = tmp.bgra;
}
