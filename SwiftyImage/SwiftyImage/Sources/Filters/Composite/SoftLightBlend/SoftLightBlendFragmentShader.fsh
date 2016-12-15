#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform sampler2D secondInput;

out vec4 color;

// ref: https://en.wikipedia.org/wiki/Blend_modes
float cal(float base, float top) {
    if (top < 0.5) {
        return base - (1.0 - 2.0 * top) * base * (1.0 - base);
    } else {
        float g;
        if (base <= 0.25) {
            g = ((16.0 * base - 12.0) * base + 4.0) * base;
        } else {
            g = sqrt(base);
        }
        return base + (2.0 * top - 1.0) * (g - base);
    }
}

void main() {
    vec4 base = texture(secondInput, fTextCoor);
    vec4 top = texture(firstInput, fTextCoor);
    
    color = vec4(cal(base.r, top.r), cal(base.g, top.g), cal(base.b, top.b), cal(base.a, top.a));
}

