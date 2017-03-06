#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform float distance;
uniform vec2 direction;
uniform float unit;

out vec4 color;


void main() {
    vec4 acc = vec4(0);
    
    vec2 dir = normalize(direction);
    float sum = 0.0;
    for (float i = -distance; i <= distance; i += unit) {
        vec4 pColor = texture(firstInput, (fTextCoor + dir * abs(i)));
        float factor = distance + 1.0 - abs(i);
        
        acc += pColor * factor;
        sum += factor;
    }
   
    color = acc / sum;
}
