#version 300 es

precision mediump float;

in vec2 fTextCoor;
uniform sampler2D firstInput;

uniform float threshold;
uniform float maxValue;
uniform int type;

out vec4 color;

void main() {
    vec4 tmp = texture(firstInput, fTextCoor);
    
    float brightness = 0.2126 * tmp.r + 0.7152 * tmp.g + 0.0722 * tmp.b;
    
    switch (type) {
        case 0:   // binary
            brightness = brightness < threshold ? 0.0 : maxValue;
            break;
            
        case 1:   // binary inverse
            brightness = brightness < threshold ? maxValue : 0.0;
            break;
            
        case 2:   // truncate
            brightness = brightness < threshold ? brightness : threshold;
            break;
            
        case 3:   // to zero
            brightness = brightness < threshold ? 0.0 : brightness;
            break;
            
        case 4:   // to zero inverse
            brightness = brightness < threshold ? brightness : 0.0;
            break;
    }
    
    vec3 rgb = clamp(vec3(brightness), vec3(0.0), vec3(1.0));
    color = vec4(rgb, tmp.a);
}
