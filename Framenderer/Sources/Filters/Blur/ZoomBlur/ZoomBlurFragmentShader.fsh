#version 300 es

precision highp float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform vec2 center;
uniform float radius;
uniform float width;
uniform float height;

out vec4 color;

void main() {
    
    vec2 dir = fTextCoor - center;
    float dist = length(dir);
    
    if (dist == 0.0) {
        color = texture(firstInput, fTextCoor);
        return;
    }
    
    float cosAlpha = dir.x / dist;
    float sinAlpha = dir.y / dist;
    
    float xUnit = cosAlpha / width;
    float yUnit = sinAlpha / height;
    float unit = sqrt(pow(xUnit, 2.0) + pow(yUnit, 2.0));
    float actualRadius = abs(radius * unit);
    
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
