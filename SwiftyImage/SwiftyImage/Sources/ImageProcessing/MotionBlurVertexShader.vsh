#version 300 es

in vec4 vPosition;
in vec2 vTextCoor;

uniform float texelWidth;
uniform float texelHeight;

out vec2 textCoor;
out vec2 oneStepForwardTextCoor;
out vec2 twoStepForwardTextCoor;
out vec2 threeStepForwardTextCoor;
out vec2 fourStepForwardTextCoor;
out vec2 fiveStepForwardTextCoor;
out vec2 sixStepForwardTextCoor;
out vec2 sevenStepForwardTextCoor;
out vec2 oneStepBackwardTextCoor;
out vec2 twoStepBackwardTextCoor;
out vec2 threeStepBackwardTextCoor;
out vec2 fourStepBackwardTextCoor;
out vec2 fiveStepBackwardTextCoor;
out vec2 sixStepBackwardTextCoor;
out vec2 sevenStepBackwardTextCoor;

void main() {
    gl_Position = vPosition;
    
    vec2 step = vec2(texelWidth, texelHeight);
    
    textCoor = vTextCoor;
    oneStepForwardTextCoor = textCoor + step;
    twoStepForwardTextCoor = textCoor + step * 2.0;
    threeStepForwardTextCoor = textCoor + step * 3.0;
    fourStepForwardTextCoor = textCoor + step * 4.0;
    fiveStepForwardTextCoor = textCoor + step * 5.0;
    sixStepForwardTextCoor = textCoor + step * 6.0;
    sevenStepForwardTextCoor = textCoor + step * 7.0;
    oneStepBackwardTextCoor = textCoor - step;
    twoStepBackwardTextCoor = textCoor - step * 2.0;
    threeStepBackwardTextCoor = textCoor - step * 3.0;
    fourStepBackwardTextCoor = textCoor - step * 4.0;
    fiveStepBackwardTextCoor = textCoor - step * 5.0;
    sixStepBackwardTextCoor = textCoor - step * 6.0;
    sevenStepBackwardTextCoor = textCoor - step * 7.0;
}
