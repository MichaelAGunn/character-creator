shader_type spatial;

render_mode unshaded;

// === Colors (only lit tones – shadows come from lighting) ===
uniform vec3 sand_light : source_color = vec3(0.94, 0.80, 0.55);  // sun-lit sand
uniform vec3 sand_mid   : source_color = vec3(0.82, 0.63, 0.38);  // slightly darker variation

// === Shape ===
uniform float dune_scale      : hint_range(0.02, 1.0) = 0.16;
uniform float ripple_scale    : hint_range(0.3, 6.0)  = 1.35;
uniform float ripple_strength : hint_range(0.0, 1.0)  = 0.5;
uniform float dune_strength   : hint_range(0.0, 1.0)  = 0.65;
uniform float normal_strength : hint_range(0.3, 3.0)  = 1.4;

// === Toon lighting ===
uniform int   light_steps      : hint_range(2, 5) = 3;
uniform float light_softness   : hint_range(0.0, 0.15) = 0.045;
uniform float ambient          : hint_range(0.0, 0.35) = 0.14;
uniform vec3  shadow_tint      : source_color = vec3(0.55, 0.38, 0.22); // optional warm tint in shadow

// Wind
uniform float wind_speed : hint_range(0.0, 0.25) = 0.012;
uniform vec2  wind_dir   = vec2(1.0, 0.22);

// -------------------------------------------------
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
    float v = 0.0;
    v += 0.500 * noise(p);
    v += 0.250 * noise(p * 2.05);
    v += 0.125 * noise(p * 4.2);
    return v;
}

float wind_ripples(vec2 p) {
    vec2 dir  = normalize(wind_dir);
    vec2 perp = vec2(-dir.y, dir.x);
    float along  = dot(p, dir)  * 0.5;
    float across = dot(p, perp) * 1.7;
    float n = fbm(vec2(along, across));
    return smoothstep(0.32, 0.72, n);
}

void fragment() {
    vec2 pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
    vec2 wind = wind_dir * TIME * wind_speed;

    float dunes   = fbm(pos * dune_scale + wind * 0.25);
    float ripples = wind_ripples(pos * ripple_scale + wind);

    float h = dunes * dune_strength + ripples * ripple_strength;

    // Albedo is only light/mid tones – no baked shadows
    float variation = smoothstep(0.35, 0.65, h);
    ALBEDO = mix(sand_mid, sand_light, variation);

    // Normals from the large shapes (this is what creates real shadows)
    float eps = 0.035;
    float hL = fbm((pos + vec2(-eps, 0.0)) * dune_scale) * dune_strength
             + wind_ripples((pos + vec2(-eps, 0.0)) * ripple_scale) * ripple_strength;
    float hR = fbm((pos + vec2( eps, 0.0)) * dune_scale) * dune_strength
             + wind_ripples((pos + vec2( eps, 0.0)) * ripple_scale) * ripple_strength;
    float hD = fbm((pos + vec2(0.0, -eps)) * dune_scale) * dune_strength
             + wind_ripples((pos + vec2(0.0, -eps)) * ripple_scale) * ripple_strength;
    float hU = fbm((pos + vec2(0.0,  eps)) * dune_scale) * dune_strength
             + wind_ripples((pos + vec2(0.0,  eps)) * ripple_scale) * ripple_strength;

    vec3 nmap = normalize(vec3(
        (hL - hR) * normal_strength,
        0.12,
        (hD - hU) * normal_strength
    ));
    NORMAL_MAP = nmap * 0.5 + 0.5;
    NORMAL_MAP_DEPTH = 1.0;
}

void light() {
    float NdotL = max(dot(NORMAL, LIGHT), 0.0);

    // Stepped toon lighting
    float stepped = floor(NdotL * float(light_steps) + 0.001) / float(light_steps);

    // Soften the band edges slightly
    float intensity = mix(stepped, NdotL, light_softness * 2.5);
    intensity = smoothstep(0.0, light_softness + 0.001, intensity);

    // Main lit contribution
    vec3 lit = ALBEDO * intensity * LIGHT_COLOR * ATTENUATION;

    // Shadow areas get a warm tint (still driven by actual light, not noise)
    float shadow_mask = 1.0 - intensity;
    vec3 shadowed = mix(lit, ALBEDO * shadow_tint * 0.7, shadow_mask);

    DIFFUSE_LIGHT += shadowed + ALBEDO * ambient * ATTENUATION;
}