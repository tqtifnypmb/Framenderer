#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform float radius;
uniform highp float xOffset;
uniform highp float yOffset;
uniform float sigma;

out vec4 color;

#define M_PI 3.1415926535897932384626433832795

void main() {
    vec4 acc = vec4(0.0);
    
    float constant1 = 2.0 * pow(sigma, 2.0);
    float constant2 = 1.0 / sqrt(constant1 * M_PI);
    
    float weightSum = 0.0;
    
    for (float row = 0.0; row <= 2.0 * radius; row += 1.0) {
        float spaceDistance = abs(row - radius);
        float spaceWeight = constant2 * exp(-spaceDistance / constant1);
        
        vec4 tmp = texture(firstInput, fTextCoor + vec2((row - radius) * xOffset, (row - radius) * yOffset));
        
        float w = spaceWeight;
        weightSum += w;
        acc += tmp * w;
    }
    
    acc = acc / weightSum;
    color = clamp(acc, vec4(0.0), vec4(1.0));
}
