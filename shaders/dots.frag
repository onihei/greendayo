precision mediump float;
out vec4 fragColor;

uniform float dotRadius;
uniform float spacing;

void main() {
    vec2 pos = mod(gl_FragCoord.xy, spacing);
    float dist = length(pos - spacing / 2.0);
    float alpha = smoothstep(dotRadius, dotRadius - 1.0, dist);
    fragColor = vec4(0, 0, 0, alpha * 0.3);
}
