#version 300 es

precision mediump float;

in vec2 fTextCoor;
uniform sampler2D firstInput;
uniform sampler2D secondInput;

out vec4 color;

// If you wanna know how to composite two pic into one, the following links
// may be helpful:
//
// https://keithp.com/~keithp/porterduff/p253-porter.pdf
// http://www.cs.princeton.edu/courses/archive/fall00/cs426/papers/smith95a.pdf

void main() {
    
    vec4 base = texture(secondInput, fTextCoor);
    vec4 top = texture(firstInput, fTextCoor);
    
    float alpha, m;
    
    m = min(top.a, base.a);
    alpha = top.a + (1.0 - top.a) * base.a;
    
    if (m > 0.0 && alpha > 0.0) {
        float ratio = m / alpha;

        float dr;
        if (base.r < 0.5) {
            dr = 2.0 * base.r * top.r;
        } else {
            dr = 1.0 - 2.0 * (1.0 - base.r) * (1.0 - top.r);
        }
        dr = dr * ratio + base.r * (1.0 - ratio);
        
        float dg;
        if (base.g < 0.5) {
            dg = 2.0 * base.g * top.g;
        } else {
            dg = 1.0 - 2.0 * (1.0 - base.g) * (1.0 - top.g);
        }
        dg = dg * ratio + base.g * (1.0 - ratio);
        
        float db;
        if (base.b < 0.5) {
            db = 2.0 * base.b * top.b;
        } else {
            db = 1.0 - 2.0 * (1.0 - base.b) * (1.0 - top.b);
        }
        db = db * ratio + base.b * (1.0 - ratio);
        
        color = vec4(dr, dg, db, top.a);
    } else {
        color = top;
    }
}
