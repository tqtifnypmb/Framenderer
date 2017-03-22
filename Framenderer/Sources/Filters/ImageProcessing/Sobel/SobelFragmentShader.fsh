#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform float radius;
uniform highp float xOffset;
uniform highp float yOffset;
uniform mat3 xKernel;
uniform mat3 yKernel;

out vec4 color;

void main() {
    float gx = 0.0;
    float gy = 0.0;
    
    for (float row = -radius; row <= radius; row += 1.0) {
        for (float col = -radius; col <= radius; col += 1.0) {
            vec4 tmp = texture(firstInput, fTextCoor + vec2(row * xOffset, col * yOffset));
            
            float intensity = tmp.r + tmp.g + tmp.b;
            
            gx += intensity * xKernel[int(col + radius)][int(row + radius)];
            gy += intensity * yKernel[int(col + radius)][int(row + radius)];
        }
    }
    
    float brightness = sqrt(pow(gx / 32.0, 2.0) + pow(gy / 32.0, 2.0));
    vec3 rgb = clamp(vec3(brightness), vec3(0.0), vec3(1.0));
    color = vec4(rgb, 1.0);
}
