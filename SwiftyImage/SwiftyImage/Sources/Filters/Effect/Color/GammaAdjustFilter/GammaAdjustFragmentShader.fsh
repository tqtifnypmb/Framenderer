#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform float adjust;

out vec4 color;

void main() {
    vec4 tmp = texture(firstInput, fTextCoor);
    
    float r = pow(tmp.r, adjust);
    float g = pow(tmp.g, adjust);
    float b = pow(tmp.b, adjust);
    color = vec4(clamp(vec3(r, g, b), vec3(0.0), vec3(1.0)), vec4(1.0));
}
