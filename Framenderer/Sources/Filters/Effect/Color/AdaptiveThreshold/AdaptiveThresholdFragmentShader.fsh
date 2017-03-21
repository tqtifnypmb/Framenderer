#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform float radius;
uniform highp float xOffset;
uniform highp float yOffset;
uniform float sigma;
uniform int method;
uniform int type;
uniform float max;

out vec4 color;

#define M_PI 3.1415926535897932384626433832795

void main() {
    vec4 acc = vec4(0.0);
    
    float spaceCons1 = 2.0 * pow(sigma, 2.0);
    float spaceCons2 = 1.0 / sqrt(spaceCons1 * M_PI);
    float mean = 1.0 / pow(2.0 * radius + 1.0, 2.0);
    
    float weightSum = 0.0;
    
    for (float row = 0.0; row <= 2.0 * radius; row += 1.0) {
        for (float col = 0.0; col <= 2.0 * radius; col += 1.0) {
            vec4 tmp = texture(firstInput, fTextCoor + vec2((row - radius) * xOffset, (col - radius) * yOffset));
            
            float w;
            if (method == 0) {      // mean
                w = mean;
            } else {
                vec2 spaceOffset = vec2(row - radius , col - radius);
                float spaceDistance = length(spaceOffset);
                float spaceWeight = spaceCons2 * exp(-spaceDistance / spaceCons1);
                w = spaceWeight;
            }
            
            weightSum += w;
            acc += tmp * w;
        }
    }
    acc = acc / weightSum;
    
    vec4 center = texture(firstInput, fTextCoor);
    
    float threshold = 0.2126 * acc.r + 0.7152 * acc.g + 0.0722 * acc.b;
    float brightness = 0.2126 * center.r + 0.7152 * center.g + 0.0722 * center.b;
    
    switch (type) {
    case 0:         // binary
            brightness = brightness < threshold ? 0.0 : max;
            break;
        
    case 1:         // binary inverse
            brightness = brightness < threshold ? max : 0.0;
            break;
        
    case 2:         // truncate
            brightness = brightness < threshold ? brightness : threshold;
            break;
        
    case 3:         // to_zero
            brightness = brightness < threshold ? 0.0 : brightness;
            break;
        
    case 4:         // to_zero_inverse
            brightness = brightness < threshold ? brightness : 0.0;
            break;
    }
    
    vec3 rgb = clamp(vec3(brightness), vec3(0.0), vec3(1.0));
    color = vec4(rgb, center.a);
}
