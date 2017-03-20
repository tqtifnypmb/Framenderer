#version 300 es

precision mediump float;

in vec2 fTextCoor;
uniform sampler2D firstInput;
out vec4 color;

void main() {
    vec4 tmp = texture(firstInput, fTextCoor);
    
    // ref: http://www.poynton.com/notes/colour_and_gamma/ColorFAQ.html#RTFToC9
    float brightness = 0.2126 * tmp.r + 0.7152 * tmp.g + 0.0722 * tmp.b;
    vec3 rgb = clamp(vec3(brightness, brightness, brightness), vec3(0.0), vec3(1.0));
    color = vec4(rgb, tmp.a);
}
