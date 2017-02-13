#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform sampler2D secondInput;

out vec4 color;

// ref: https://en.wikipedia.org/wiki/Blend_modes
void main() {
    vec4 top = texture(secondInput, fTextCoor);
    vec4 bottom = texture(firstInput, fTextCoor);
    
    float lightness = (top.r + top.g + top.b) * top.a / 3.0;
    vec3 tmp;
    if (lightness < 0.5) {
        tmp = bottom.rgb - (vec3(1.0) - vec3(2.0) * top.rgb) * bottom.rgb * (vec3(1.0) - bottom.rgb);
    } else {
        float lightness2 = (bottom.r + bottom.g + bottom.b) * bottom.a / 3.0;
        vec3 g;
        if (lightness2 < 0.25) {
            g = ((vec3(16.0) * bottom.rgb - vec3(12.0)) * bottom.rgb + vec3(4.0)) * bottom.rgb;
        } else {
            g = vec3(sqrt(bottom.r), sqrt(bottom.g), sqrt(bottom.b));
        }
        tmp = bottom.rgb + (vec3(2.0) * top.rgb - vec3(1.0)) * (g - bottom.rgb);
    }
    tmp = tmp * top.a * bottom.a + bottom.rgb * (1.0 - bottom.a * top.a);
    color = vec4(clamp(tmp, vec3(0.0), vec3(1.0)), 1.0);
} 
