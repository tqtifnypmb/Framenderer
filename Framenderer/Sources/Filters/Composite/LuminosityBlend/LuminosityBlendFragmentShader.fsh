#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform sampler2D secondInput;

out vec4 color;

// https://en.wikipedia.org/wiki/HSL_and_HSV

#define undefined 1000.0

vec3 rgb2hsl(vec3 rgb) {
    float M = max(max(rgb.r, rgb.b), rgb.b);
    float m = min(min(rgb.r, rgb.b), rgb.b);
    float C = M - m;
    
    float luma = (M + m) / 2.0;//dot(rgb, vec3(0.3, 0.59, 0.11));
    
    float hue;
    if (C == 0.0) {
        hue = undefined;
    } else if (M == rgb.r) {
        hue = 60.0 * mod(((rgb.g - rgb.b) / C), 60.0);
    } else if (M == rgb.g) {
        hue = 60.0 * ((rgb.b - rgb.r) / C + 2.0);
    } else if (M == rgb.b) {
        hue = 60.0 * ((rgb.r - rgb.g) / C + 4.0);
    }
    
    float sat = 0.0;
    if (luma != 1.0) {
        sat = C / (1.0 - abs(2.0 * luma - 1.0));
    }
    
    return vec3(hue, sat, luma);
}

vec3 hsl2rgb(vec3 hsl) {
    vec3 tmp;
    if (hsl.r == undefined) {
        return vec3(0.0);
    } else {
        float C = (1.0 - abs(2.0 * hsl.b - 1.0)) * hsl.g;
        float H1 = hsl.r / 60.0;
        float X = C * (1.0 - abs(mod(H1, 2.0) - 1.0));
        
        if (H1 >= 0.0 && H1 < 1.0) {
            tmp = vec3(C, X, 0.0);
        } else if (H1 >= 1.0 && H1 < 2.0) {
            tmp = vec3(X, C, 0.0);
        } else if (H1 >= 2.0 && H1 < 3.0) {
            tmp = vec3(0.0, C, X);
        } else if (H1 >= 3.0 && H1 < 4.0) {
            tmp = vec3(0.0, X, C);
        } else if (H1 >= 4.0 && H1 < 5.0) {
            tmp = vec3(X, 0.0, C);
        } else if (H1 >= 5.0 && H1 <= 6.0) {
            tmp = vec3(C, 0.0, X);
        }
        float m = hsl.b - C / 2.0;
        return tmp + vec3(m);
    }
}

void main() {
    vec4 top = texture(secondInput, fTextCoor);
    vec4 bottom = texture(firstInput, fTextCoor);
    
    vec3 hsl_top = rgb2hsl(top.rgb);
    vec3 hsl_bottom = rgb2hsl(bottom.rgb);
    vec3 hsl_final = vec3(hsl_bottom.r, hsl_bottom.g, hsl_top.b);
    
    vec3 tmp = hsl2rgb(hsl_final);
    tmp = tmp * top.a * bottom.a + bottom.rgb * (1.0 - top.a) * (1.0 - bottom.a);
    color = vec4(clamp(tmp, vec3(0.0), vec3(1.0)), 1.0);
}
