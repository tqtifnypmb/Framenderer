#version 300 es

precision mediump float;

in vec2 textCoor;
in vec2 oneStepTextCoor;
in vec2 twoStepTextCoor;
in vec2 threeStepTextCoor;
in vec2 fourStepTextCoor;
in vec2 fiveStepTextCoor;
in vec2 sixStepTextCoor;

uniform sampler2D firstInput;
out vec4 color;


void main() {
    vec4 acc = vec4(0);
    
    acc += texture(firstInput, textCoor) * 0.2128;
    acc += texture(firstInput, oneStepTextCoor) * 0.2128;
    acc += texture(firstInput, twoStepTextCoor) * 0.2128;
    acc += texture(firstInput, threeStepTextCoor) * 0.1428;
    acc += texture(firstInput, fourStepTextCoor) * 0.0728;
    acc += texture(firstInput, fiveStepTextCoor) * 0.0728;
    acc += texture(firstInput, sixStepTextCoor) * 0.0728;
   
    color = acc;
}
