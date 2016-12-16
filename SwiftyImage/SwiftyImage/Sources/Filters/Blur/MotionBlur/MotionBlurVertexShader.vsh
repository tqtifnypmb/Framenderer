#version 300 es

in vec4 vPosition;
in vec2 vTextCoor;

uniform float xOffset;
uniform float yOffset;

out vec2 textCoor;
out vec2 oneStepTextCoor;
out vec2 twoStepTextCoor;
out vec2 threeStepTextCoor;
out vec2 fourStepTextCoor;
out vec2 fiveStepTextCoor;
out vec2 sixStepTextCoor;

void main() {
    gl_Position = vPosition;
    
    vec2 step = vec2(xOffset, yOffset);
    
    textCoor = vTextCoor;
    oneStepTextCoor = textCoor + step;
    twoStepTextCoor = textCoor + step * 2.0;
    threeStepTextCoor = textCoor + step * 3.0;
    fourStepTextCoor = textCoor + step * 4.0;
    fiveStepTextCoor = textCoor + step * 5.0;
    sixStepTextCoor = textCoor + step * 6.0;
}
