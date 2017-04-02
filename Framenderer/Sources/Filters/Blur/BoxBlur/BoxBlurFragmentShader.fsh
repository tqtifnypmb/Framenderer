#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform int radius;
uniform highp float xOffset;
uniform highp float yOffset;

out vec4 color;

void main() {
    vec4 acc = vec4(0.0);
    
    float weight = 1.0 / (float(radius) * 2.0 + 1.0);
    
    for (int row = -radius; row <= radius; row += 1) {
        vec4 tmp = texture(firstInput, fTextCoor + vec2(float(row) * xOffset, float(row) * yOffset));
        acc += tmp * weight;
    }
    
    color = clamp(acc, vec4(0.0), vec4(1.0));
}
