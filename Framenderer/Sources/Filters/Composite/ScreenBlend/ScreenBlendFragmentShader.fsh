#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform sampler2D secondInput;

out vec4 color;

void main() {
    vec4 top = texture(secondInput, fTextCoor);
    vec4 bottom = texture(firstInput, fTextCoor);
    
    vec3 tmp = vec3(1.0) - (vec3(1.0) - bottom.rgb) * (vec3(1.0) - top.rgb);
    tmp = tmp * top.a * bottom.a + top.rgb * top.a * (1.0 - bottom.a) + bottom.rgb * bottom.a * (1.0 - top.a) + top.rgb * (1.0 - top.a) * (1.0 - bottom.a);
    color = vec4(clamp(tmp, vec3(0.0), vec3(1.0)), 1.0);
}

