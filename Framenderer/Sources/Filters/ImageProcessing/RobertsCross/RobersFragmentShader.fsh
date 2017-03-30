#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;
uniform highp float xOffset;
uniform highp float yOffset;

out vec4 color;

void main() {
    vec4 topleft = texture(firstInput, fTextCoor);
    vec4 topright = texture(firstInput, fTextCoor + vec2(xOffset, 0));
    vec4 bottomleft = texture(firstInput, fTextCoor + vec2(0, yOffset));
    vec4 bottomright = texture(firstInput, fTextCoor + vec2(xOffset, yOffset));
    
    vec4 tmp = topleft - bottomright;
    float gx = tmp.r + tmp.g + tmp.b;
    
    tmp = topright - bottomleft;
    float gy = tmp.r + tmp.g + tmp.b;
    
    float brightness = length(vec2(gx, gy));
    vec3 rgb = clamp(vec3(brightness), vec3(0.0), vec3(1.0));
    color = vec4(rgb, 1.0);
}
