#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform sampler2D secondInput;

out vec4 color;

void main() {
    vec4 top = texture(secondInput, fTextCoor);
    vec4 bottom = texture(firstInput, fTextCoor);
    
    float brightness_top = top.a * (top.r + top.g + top.b);
    float brightness_bottom = bottom.a * (bottom.r + bottom.g + bottom.b);
    vec3 tmp;
    
    if (brightness_top > brightness_bottom) {
        tmp = top.rgb * (top.a * bottom.a) + bottom.rgb * (1.0 - top.a * bottom.a);
    } else {
        tmp = bottom.rgb;
    }
    color = vec4(clamp(tmp, vec3(0.0), vec3(1.0)), 1.0);
}

