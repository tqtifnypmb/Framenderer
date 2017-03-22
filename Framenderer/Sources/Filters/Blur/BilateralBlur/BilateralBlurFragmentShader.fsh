#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform float radius;
uniform highp float xOffset;
uniform highp float yOffset;
uniform float colorSigma;
uniform float spaceSigma;

out vec4 color;

#define M_PI 3.1415926535897932384626433832795

void main() {    
    vec4 colorCenter = texture(firstInput, fTextCoor);
    vec4 acc = vec4(0.0);
    
    float spaceCons1 = 2.0 * pow(spaceSigma, 2.0);
    float spaceCons2 = 1.0 / sqrt(spaceCons1 * M_PI);
    
    float colorCons1 = 2.0 * pow(colorSigma, 2.0);
    float colorCons2 = 1.0 / sqrt(colorSigma * M_PI);

    float weightSum = 0.0;

    for (float row = -radius; row <=  radius; row += 1.0) {
        float spaceDistance = abs(row);
        float spaceWeight = spaceCons2 * exp(-spaceDistance / spaceCons1);
        
        vec4 tmp = texture(firstInput, fTextCoor + vec2(row * xOffset, row * yOffset));
        
        float colorDistance = distance(tmp, colorCenter);
        float colorWeight = colorCons2 * exp(-colorDistance / colorCons1);
        
        float w = spaceWeight * (1.0 - colorWeight);
        weightSum += w;
        acc += tmp * w;
    }
        
    acc = acc / weightSum;
    color = clamp(acc, vec4(0.0), vec4(1.0));
}
