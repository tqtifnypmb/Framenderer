#version 300 es

precision mediump float;

in vec2 fLTTextCoor;
in vec2 fMTTextCoor;
in vec2 fRTTextCoor;
in vec2 fLMTextCoor;
in vec2 fCenterTextCoor;
in vec2 fRMTextCoor;
in vec2 fLBTextCoor;
in vec2 fMBTextCoor;
in vec2 fRBTextCoor;

uniform sampler2D firstInput;

out vec4 color;

void main() {
    vec4 sum = vec4(0.0);
    
    sum += texture(firstInput, fLTTextCoor) / 9.0;
    sum += texture(firstInput, fMTTextCoor) / 9.0;
    sum += texture(firstInput, fRTTextCoor) / 9.0;
    sum += texture(firstInput, fLMTextCoor) / 9.0;
    sum += texture(firstInput, fCenterTextCoor) / 9.0;
    sum += texture(firstInput, fRMTextCoor) / 9.0;
    sum += texture(firstInput, fLBTextCoor) / 9.0;
    sum += texture(firstInput, fMBTextCoor) / 9.0;
    sum += texture(firstInput, fRBTextCoor) / 9.0;
    
    color = sum;
}
