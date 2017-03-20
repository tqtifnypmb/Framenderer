#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform sampler2D secondInput;

out vec4 color;

void main() {
    vec4 top = texture(secondInput, fTextCoor);
    vec4 bottom = texture(firstInput, fTextCoor);
    
    // ref: http://www.poynton.com/notes/colour_and_gamma/ColorFAQ.html#RTFToC9
    float brightness_top = top.a * (0.2126 * top.r + 0.7152 * top.g + 0.0722 * top.b);
    float brightness_bottom = bottom.a * (0.2126 * bottom.r + 0.7152 * bottom.g + 0.0722 * bottom.b);
    vec3 tmp;
    if (brightness_top > brightness_bottom) {
        tmp = top.rgb - bottom.rgb;
        tmp = tmp * (top.a * bottom.a) + top.rgb * (1.0 - top.a * bottom.a);
    } else {
        tmp = bottom.rgb - top.rgb;
        tmp = tmp * (top.a * bottom.a) + bottom.rgb * (1.0 - top.a * bottom.a);
    }
    color = vec4(clamp(tmp, vec3(0.0), vec3(1.0)), 1.0);
}
