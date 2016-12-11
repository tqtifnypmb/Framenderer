#version 300 es

in vec4 vPosition;
in vec2 vTextCoor;

uniform float texelWidth;
uniform float texelHeight;

out vec2 fLTTextCoor;
out vec2 fMTTextCoor;
out vec2 fRTTextCoor;
out vec2 fLMTextCoor;
out vec2 fCenterTextCoor;
out vec2 fRMTextCoor;
out vec2 fLBTextCoor;
out vec2 fMBTextCoor;
out vec2 fRBTextCoor;

void main() {
    gl_Position = vPosition;
    
    vec2 hStep = vec2(texelWidth, 0);
    vec2 vStep = vec2(0, texelHeight);
    vec2 dStep = vec2(texelWidth, texelHeight);
    
    fLTTextCoor = vTextCoor - dStep;
    fMTTextCoor = vTextCoor - vStep;
    fRTTextCoor = fMTTextCoor + hStep;
    fLMTextCoor = vTextCoor - hStep;
    fCenterTextCoor = vTextCoor;
    fRMTextCoor = vTextCoor + hStep;
    fLBTextCoor = vTextCoor - dStep;
    fMBTextCoor = vTextCoor - vStep;
    fRBTextCoor = fMBTextCoor + hStep;
}
