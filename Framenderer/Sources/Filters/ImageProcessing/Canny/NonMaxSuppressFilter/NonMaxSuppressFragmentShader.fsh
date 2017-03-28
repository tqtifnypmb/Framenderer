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
        if (center.a == 2.0) {
            step = vec2(0.0, yOffset);
        } else {
            step = vec2(xOffset, abs(xOffset * center.a));
        }
        
        int radius = 1;
        for (int row = -radius; row <= radius; row += 1) {
            vec2 offset = step * float(row);
            vec4 tmp = texture(firstInput, fTextCoor + offset);
            
            if (intensity < tmp.r) {
                intensity = 0.0;
                break;
            }
        }
        
        vec3 rgb = clamp(vec3(intensity), vec3(0.0), vec3(1.0));
        color = vec4(rgb, 1.0);
    }
}
