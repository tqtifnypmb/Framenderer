#version 300 es

precision mediump float;

in vec2 fTextCoor;
uniform sampler2D firstInput;
uniform sampler2D secondInput;
out vec4 color;

//Equivalent to Overlay, but with the bottom and top images swapped.
void main() {
    vec4 bottom = texture(secondInput, fTextCoor);
    vec4 top = texture(firstInput, fTextCoor);
    
    float lightness = bottom.a * (bottom.r + bottom.g + bottom.b) / 3.0;
    vec3 tmp;
    if (lightness < 0.5) {
        tmp = vec3(2.0) * bottom.rgb * top.rgb;
    } else {
        tmp = vec3(1.0) - vec3(2.0) * (vec3(1.0) - bottom.rgb) * (vec3(1.0) - top.rgb);
    }
    tmp = tmp * top.a * bottom.a + bottom.rgb * (1.0 - top.a * bottom.a);
    color = vec4(clamp(tmp, vec3(0.0), vec3(1.0)), 1.0);
}
