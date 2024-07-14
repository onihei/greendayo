precision mediump float;
out vec4 fragColor;
uniform vec2 iResolution;
uniform float iTime;

void main() {
    vec2 fragCoord = gl_FragCoord.xy;
    float aspect = iResolution.y / iResolution.x;
    float value;
    vec2 uv = fragCoord.xy / iResolution.x;
    uv -= vec2(0.5, 0.5 * aspect);
    float rot = radians(35.0);
    mat2 m = mat2(cos(rot), -sin(rot), sin(rot), cos(rot));
    uv = m * uv;
    uv += vec2(0.2, 0.5 * aspect);
    uv.y += 0.5 * (1.0 - aspect);
    vec2 pos = 10.0 * uv;
    vec2 rep = fract(pos);
    float dist = 2.0 * min(min(rep.x, 1.0 - rep.x), min(rep.y, 1.0 - rep.y));
    float squareDist = length((floor(pos) + vec2(0.1)) - vec2(5.0));

    float edge = sin(iTime - squareDist * 0.5) * 0.5 + 0.5;
    edge = (iTime - squareDist * 0.1) * 0.2;
    edge = 2.0 * fract(edge * 0.5);
    value = fract(dist * 1.0);
    value = mix(value, 1.0 - value, step(1.0, edge));
    edge = pow(abs(1.0 - edge), 2.0);
    value = smoothstep(edge - 0.05, edge, 0.15 * value);
    value += squareDist * 0.1;

    fragColor = mix(vec4(1.0, 0.4, 1.0, 1.0), vec4(0.1, 0.75, 1.0, 1.0), value);
    fragColor.a = 0.1 * clamp(value, 0.0, 1.0);
}