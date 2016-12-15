#version 300 es

precision mediump float;

in vec2 fTextCoor;
uniform sampler2D firstInput;
uniform sampler2D secondInput;
out vec4 color;


void main() {
    vec4 top = texture(secondInput, fTextCoor);
    vec4 base = texture(firstInput, fTextCoor);
    
    float alpha;
    alpha = top.a + (1.0 - top.a) * base.a;
    
    if (alpha > 0.0) {
        float dr;
        if (base.r < 0.5) {
            dr = 2.0 * base.r * top.r;
        } else {
            dr = 1.0 - 2.0 * (1.0 - base.r) * (1.0 - top.r);
        }
        dr = dr * alpha + base.r * (1.0 - alpha);
        
        float dg;
        if (base.g < 0.5) {
            dg = 2.0 * base.g * top.g;
        } else {
            dg = 1.0 - 2.0 * (1.0 - base.g) * (1.0 - top.g);
        }
        dg = dg * alpha + base.g * (1.0 - alpha);
        
        float db;
        if (base.b < 0.5) {
            db = 2.0 * base.b * top.b;
        } else {
            db = 1.0 - 2.0 * (1.0 - base.b) * (1.0 - top.b);
        }
        db = db * alpha + base.b * (1.0 - alpha);
        
        color = vec4(dr / alpha, dg / alpha, db / alpha, alpha);
    } else {
        color = top;
    }
}
