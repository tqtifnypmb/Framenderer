#version 300 es

precision mediump float;

in vec2 fTextCoor;

uniform sampler2D firstInput;   // Y-planar
uniform sampler2D secondInput;  // UV-planar

uniform mat3 transform;

out vec4 color;

// ref: https://en.wikipedia.org/wiki/YUV

void main() {
    vec3 yuv;
    vec3 rgb;

    yuv.x = texture(firstInput, fTextCoor).r;
    
    /* Need help here #_#:
     *      1. how UV data layout
     *      2. how to retrieve that data
     */
    yuv.yz = texture(secondInput, fTextCoor).rg;

    rgb = transform * yuv;
    color = vec4(clamp(vec3(0.0), vec3(1.0), rgb), 1.0);
}
