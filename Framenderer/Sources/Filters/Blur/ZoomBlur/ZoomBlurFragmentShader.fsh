#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform vec2 center;
uniform float radius;
uniform float width;
uniform float height;

out vec4 color;

void main() {
    
    vec2 dir = fTextCoor - center;
    float distance = sqrt(pow(dir.x, 2.0) + pow(dir.y, 2.0));
    
    if (distance == 0.0) {
        color = texture(firstInput, fTextCoor);
        return;
    }
    
    float cosAlpha = dir.x / distance;
    float sinAlpha = dir.y / distance;
    
    float xUnit = cosAlpha / width;
    float yUnit = sinAlpha / height;
    float unit = sqrt(pow(xUnit, 2.0) + pow(yUnit, 2.0));
    float actualRadius = radius * unit;
    
    vec4 acc = vec4(0);
    int j = 0;
    float sum = 0.0;
    for (float i = -actualRadius; i <= actualRadius; i += unit) {
        vec2 pos = fTextCoor + vec2(xUnit * float(j), yUnit * float(j));
        ++j;
        
        float factor = actualRadius + 1.0 - abs(i);
        acc += texture(firstInput, pos) * factor;
        sum += factor;
    }
    
    color = acc / sum;
}
