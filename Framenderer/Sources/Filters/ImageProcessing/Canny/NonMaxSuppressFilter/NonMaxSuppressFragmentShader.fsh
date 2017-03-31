#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform highp float xOffset;
uniform highp float yOffset;
uniform float lower;
uniform float upper;

out vec4 color;

void main() {
    vec4 center = texture(firstInput, fTextCoor);
    float intensity = center.r;
    
    if (intensity < lower || intensity > upper) {
        color = vec4(vec3(0.0), 1.0);
    } else {
        vec2 step;
        if (tan(center.a) == 0.0) {
            step = vec2(xOffset, xOffset * tan(center.a));
        } else {
            step = vec2(yOffset / tan(center.a), yOffset);
        }
        
        vec4 left = texture(firstInput, fTextCoor + step * -1.0);
        if (intensity < left.r) {
            intensity = 0.0;
        } else {
            vec4 right = texture(firstInput, fTextCoor + step);
            if (intensity < right.r) {
                intensity = 0.0;
            }
        }
        
        vec3 rgb = clamp(vec3(intensity), vec3(0.0), vec3(1.0));
        color = vec4(rgb, 1.0);
    }
}
