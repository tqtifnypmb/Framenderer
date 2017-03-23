#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform float radius;
uniform highp float xOffset;
uniform highp float yOffset;

out vec4 color;

void main() {
    vec4 center = texture(firstInput, fTextCoor);
    float minimum = 0.2126 * center.r + 0.7152 * center.g + 0.0722 * center.b;
    
    for (float row = -radius; row <= radius; row += 1.0) {
        for (float col = -radius; col <= radius; col += 1.0) {
            vec4 tmp = texture(firstInput, fTextCoor + vec2(row * xOffset, col * yOffset));
            float brightness = 0.2126 * tmp.r + 0.7152 * tmp.g + 0.0722 * tmp.b;
            minimum = min(minimum, brightness);
        }
    }
    
    vec3 rgb = clamp(vec3(minimum), vec3(0.0), vec3(1.0));
    color = vec4(rgb, center.a);
}
