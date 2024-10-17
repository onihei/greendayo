out vec4 fragColor;
uniform vec2 iResolution;
uniform float iTime;

void main() {
    vec2 uv = (gl_FragCoord.xy / iResolution.x - vec2(0.5, 0.5)) * 2.0;

    float angle = atan(uv.y, uv.x) + iTime;
    float radius = length(uv);

    float spiralAngle = angle * 4.0;
    float spiralRadius = radius;

    float spiral = sin(2 * spiralAngle + spiralRadius * 10.0);
    vec3 color = 0.5 + 0.5 * cos(vec3(spiral, spiral + 2.0, spiral + 4.0));

    fragColor = vec4(color, 1.0);
}