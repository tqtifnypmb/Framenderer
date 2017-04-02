#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform highp float xOffset;
uniform highp float yOffset;
uniform float lower;
uniform float upper;

out vec4 color;

#define M_PI 3.1415926535897932384626433832795

void main() {
    vec4 center = texture(firstInput, fTextCoor);
    float intensity = center.r;
    
    if (intensity < lower || intensity > upper) {
        color = vec4(vec3(0.0), 1.0);
    } else {
        float angle = abs(center.a);
        float tangent = 0.0;
        if (angle >= 0.0 && angle <= M_PI / 8.0) {        // [0, 22.5]
            tangent = 0.0;
        } else if (angle > M_PI / 8.0 && angle <= 3.0 * M_PI / 8.0) {       // (22.5, 67.5]
            tangent = 1.0;
        } else if (angle > 3.0 * M_PI / 8.0 && angle <= 5.0 * M_PI / 8.0) {     // (67.5, 112.5]
            tangent = 2.0;
        } else if (angle > 5.0 * M_PI / 8.0 && angle <= 7.0 * M_PI / 8.0) {      // (112.5, 157.5)
            tangent = -1.0;
        } else if (angle > 7.0 * M_PI / 8.0 && angle <= M_PI) {             // [157.5, 180]
            tangent = 0.0;
        }
        
        vec2 step;
        if (tangent == 2.0) {
            step = vec2(0.0, yOffset);
        } else {
            step = vec2(xOffset, xOffset * tangent);
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
        color = vec4(rgb, center.a);
    }
}
