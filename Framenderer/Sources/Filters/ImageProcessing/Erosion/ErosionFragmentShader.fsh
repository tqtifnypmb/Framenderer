#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform int radius;
uniform highp float xOffset;
uniform highp float yOffset;

out vec4 color;

void main() {
    vec4 center = texture(firstInput, fTextCoor);
    float minimum = 0.2126 * center.r + 0.7152 * center.g + 0.0722 * center.b;
    
    for (int row = -radius; row <= radius; row += 1) {
        for (int col = -radius; col <= radius; col += 1) {
            vec2 offset = vec2(float(row) * xOffset, float(col) * yOffset);
            vec4 tmp = texture(firstInput, fTextCoor + offset);
            float brightness = 0.2126 * tmp.r + 0.7152 * tmp.g + 0.0722 * tmp.b;
            minimum = min(minimum, brightness);
        }
    }
    
    vec3 rgb = clamp(vec3(minimum), vec3(0.0), vec3(1.0));
    color = vec4(rgb, center.a);
}
