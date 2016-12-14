#version 300 es

precision mediump float;

in vec2 fTextCoor;
uniform sampler2D firstInput;
uniform sampler2D secondInput;

out vec4 color;

void main() {
    
    vec4 base = texture(secondInput, fTextCoor);
    vec4 top = texture(firstInput, fTextCoor);
    
    float alpha, composedAlpha;
    
    composedAlpha = min(base.a, top.a);
    alpha = base.a + (1.0 - base.a) * composedAlpha;
    
    if (composedAlpha > 0.0 && alpha > 0.0) {
        float ratio = composedAlpha / alpha;
        
        vec3 tmp;
        tmp = clamp(top.rgb * base.rgb, vec3(0.0), vec3(1.0));
        color = vec4(tmp * ratio + base.rgb * (1.0 - ratio), base.a);
    } else {
        color = base;
    }
}
