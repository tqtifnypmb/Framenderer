#version 300 es

precision mediump float;

in vec2 textCoor;
in vec2 oneStepForwardTextCoor;
in vec2 twoStepForwardTextCoor;
in vec2 threeStepForwardTextCoor;
in vec2 fourStepForwardTextCoor;
in vec2 fiveStepForwardTextCoor;
in vec2 sixStepForwardTextCoor;
in vec2 sevenStepForwardTextCoor;
in vec2 oneStepBackwardTextCoor;
in vec2 twoStepBackwardTextCoor;
in vec2 threeStepBackwardTextCoor;
in vec2 fourStepBackwardTextCoor;
in vec2 fiveStepBackwardTextCoor;
in vec2 sixStepBackwardTextCoor;
in vec2 sevenStepBackwardTextCoor;

uniform sampler2D firstInput;
out vec4 color;

void main() {
    vec4 acc = vec4(0);
    
    acc += texture(firstInput, textCoor) * 0.102467255241644;
    acc += texture(firstInput, oneStepForwardTextCoor) * 0.0904270353670957;
    acc += texture(firstInput, twoStepForwardTextCoor) * 0.0798015786213696;
    acc += texture(firstInput, threeStepForwardTextCoor) * 0.0704246459547198;
    acc += texture(firstInput, fourStepForwardTextCoor) * 0.062149531920657;
    acc += texture(firstInput, fiveStepForwardTextCoor) * 0.0548467694170622;
    acc += texture(firstInput, sixStepForwardTextCoor) * 0.0484021041273289;
    acc += texture(firstInput, sevenStepForwardTextCoor) * 0.0427147069709448;
    
    acc += texture(firstInput, oneStepBackwardTextCoor) * 0.0904270353670957;
    acc += texture(firstInput, twoStepBackwardTextCoor) * 0.0798015786213696;
    acc += texture(firstInput, threeStepBackwardTextCoor) * 0.0704246459547198;
    acc += texture(firstInput, fourStepBackwardTextCoor) * 0.062149531920657;
    acc += texture(firstInput, fiveStepBackwardTextCoor) * 0.0548467694170622;
    acc += texture(firstInput, sixStepBackwardTextCoor) * 0.0484021041273289;
    acc += texture(firstInput, sevenStepBackwardTextCoor) * 0.0427147069709448;
    color = acc;
}
