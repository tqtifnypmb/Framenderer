#version 300 es

precision highp float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform float radius;
uniform vec2 offset;
uniform float unit;

out vec4 color;

void main() {
    vec4 acc = vec4(0);

    float sum = 0.0;
    int j = 0;
    for (float i = -radius; i <= radius; i += unit) {
        vec4 pColor = texture(firstInput, (fTextCoor + offset * float(j++)));
        float factor = radius + 1.0 - abs(i);
        
        acc += pColor * factor;
        sum += factor;
    }
    
    color = acc / sum;
}
