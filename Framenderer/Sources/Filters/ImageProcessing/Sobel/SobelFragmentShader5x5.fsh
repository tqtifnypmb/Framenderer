#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform highp float xOffset;
uniform highp float yOffset;
uniform float[25] xKernel;
uniform float[25] yKernel;

out vec4 color;

void main() {
    float gx = 0.0;
    float gy = 0.0;
    
    int radius = 2;
    for (int row = -radius; row <= radius; row += 1) {
        for (int col = -radius; col <= radius; col += 1) {
            vec2 offset = vec2(float(row) * xOffset, float(col) * yOffset);
            vec4 tmp = texture(firstInput, fTextCoor + offset);
            
            float intensity = 0.2126 * tmp.r + 0.7152 * tmp.g + 0.0722 * tmp.b;
            
            int cIndex = col + radius;
            int rIndex = row + radius;
            
            gx += intensity * xKernel[cIndex + 5 * rIndex];
            gy += intensity * yKernel[cIndex + 5 * rIndex];
        }
    }
    
    float brightness = sqrt(pow(gx / 240.0, 2.0) + pow(gy / 240.0, 2.0));
    vec3 rgb = clamp(vec3(brightness), vec3(0.0), vec3(1.0));
    color = vec4(rgb, 1.0);
}
