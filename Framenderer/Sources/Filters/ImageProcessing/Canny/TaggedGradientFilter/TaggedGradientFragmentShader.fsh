#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform highp float xOffset;
uniform highp float yOffset;
uniform mat3 xKernel;
uniform mat3 yKernel;

out vec4 color;

void main() {
    float gx = 0.0;
    float gy = 0.0;
    int radius = 1;
    
    vec4 center = texture(firstInput, fTextCoor);
    
    for (int row = -radius; row <= radius; row += 1) {
        for (int col = -radius; col <= radius; col += 1) {
            vec2 offset = vec2(float(row) * xOffset, float(col) * yOffset);
            vec4 tmp = texture(firstInput, fTextCoor + offset);
            
            float intensity = tmp.r + tmp.g + tmp.b;
            
            gx += intensity * xKernel[col + radius][row + radius];
            gy += intensity * yKernel[col + radius][row + radius];
        }
    }
    
    float brightness = sqrt(pow(gx / 32.0, 2.0) + pow(gy / 32.0, 2.0)) * center.a;
    vec3 rgb = clamp(vec3(brightness), vec3(0.0), vec3(1.0));
    
    float direction;
    if (gx != 0.0) {
        direction = gy / gx;
    } else {
        direction = 2.0;  // perpendicular to x
    }

    color = vec4(rgb, direction);
}
