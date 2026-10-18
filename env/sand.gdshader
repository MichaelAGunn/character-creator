shader_type spatial;

render_mode unshaded; // We handle all lighting ourselves in light()

// === Colors ===
uniform vec3 sand_color_light : source_color = vec3(0.95, 0.85, 0.65);
uniform vec3 sand_color_dark  : source_color = vec3(0.68, 0.52, 0.32);
uniform float color_contrast : hint_range(0.0, 2.0) = 1.15;

// Shadow / toon colors
uniform vec3 shadow_tint : source_color = vec3(0.55, 0.42, 0.28); // warmer dark sand in shadow
uniform float shadow_strength : hint_range(0.0, 1.0) = 0.75;

// === Scales ===
uniform float grain_scale : hint_range(0.5, 50.0) = 16.0;
uniform float ripple_scale : hint_range(0.1, 10.0) = 2.6;
uniform float dune_scale : hint_range(0.01, 2.0) = 0.3;

// === Strengths ===
uniform float grain_strength : hint_range(0.0, 1.0) = 0.4;
uniform float ripple_strength : hint_range(0.0, 1.0) = 0.6;
uniform float normal_strength : hint_range(0.0, 2.0) = 1.1;

// Toon lighting controls
uniform int light_steps : hint_range(2, 6) = 3;          // number of lighting bands
uniform float light_softness : hint_range(0.0, 0.15) = 0.03; // edge softness (0 = pure hard)
uniform float ambient_strength : hint_range(0.0, 0.6) = 0.25;

// Wind
uniform float wind_speed : hint_range(0.0, 0.5) = 0.025;
uniform vec2 wind_direction = vec2(1.0, 0.3);

// -------------------------------------------------
// Noise helpers (same as before)
// -------------------------------------------------
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float value_noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    for (int i = 0; i < octaves; i++) {
        value += amplitude * value_noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

float ripple(vec2 p) {
    vec2 dir = normalize(wind_direction);
    vec2 perp = vec2(-dir.y, dir.x);
    float along = dot(p, dir);
    float across = dot(p, perp);

    float n = fbm(vec2(along * 0.65, across * 2.6), 4);
    n = pow(abs(n * 2.0 - 1.0), 1.5);
    return n;
}

void fragment() {
    vec2 world_xz = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xz;
    vec2 wind_offset = wind_direction * TIME * wind_speed;

    float grain   = fbm(world_xz * grain_scale + wind_offset * 2.2, 5);
    float ripples = ripple(world_xz * ripple_scale + wind_offset);
    float dunes   = fbm(world_xz * dune_scale + wind_offset * 0.25, 3);

    float height = grain * grain_strength
                 + ripples * ripple_strength
                 + dunes * 0.4;

    // Base albedo with variation
    float color_factor = smoothstep(0.28, 0.72, height * color_contrast);
    vec3 base_albedo = mix(sand_color_dark, sand_color_light, color_factor);
    base_albedo *= mix(0.9, 1.06, grain);

    ALBEDO = base_albedo;

    // Store height in ALPHA or use a varying if needed later
    // (we mainly need it for visual variation)

    // Procedural normal
    float eps = 0.018;
    float hL = fbm((world_xz + vec2(-eps, 0.0)) * grain_scale, 4) * grain_strength
             + ripple((world_xz + vec2(-eps, 0.0)) * ripple_scale) * ripple_strength;
    float hR = fbm((world_xz + vec2( eps, 0.0)) * grain_scale, 4) * grain_strength
             + ripple((world_xz + vec2( eps, 0.0)) * ripple_scale) * ripple_strength;
    float hD = fbm((world_xz + vec2(0.0, -eps)) * grain_scale, 4) * grain_strength
             + ripple((world_xz + vec2(0.0, -eps)) * ripple_scale) * ripple_strength;
    float hU = fbm((world_xz + vec2(0.0,  eps)) * grain_scale, 4) * grain_strength
             + ripple((world_xz + vec2(0.0,  eps)) * ripple_scale) * ripple_strength;

    vec3 nmap = normalize(vec3(hL - hR, 2.0 * eps / max(normal_strength, 0.01), hD - hU));
    NORMAL_MAP = nmap * 0.5 + 0.5;
    NORMAL_MAP_DEPTH = normal_strength;
}

void light() {
    // Classic toon / cel lighting
    float NdotL = max(dot(NORMAL, LIGHT), 0.0);

    // Quantize into bands
    float stepped = floor(NdotL * float(light_steps)) / float(light_steps);

    // Optional soft edge
    float soft = smoothstep(0.0, light_softness, fract(NdotL * float(light_steps)));
    float intensity = mix(stepped, NdotL, light_softness * 4.0); // blend for softness control
    intensity = mix(stepped, intensity, soft);

    // Final diffuse contribution
    vec3 light_contrib = intensity * ATTENUATION * LIGHT_COLOR;

    // Apply shadow tint when in shadow
    float shadow_mask = 1.0 - intensity;
    vec3 final = mix(ALBEDO * light_contrib, ALBEDO * shadow_tint * shadow_strength, shadow_mask * 0.7);

    DIFFUSE_LIGHT += final;

    // Very soft ambient so pure black shadows don't happen
    DIFFUSE_LIGHT += ALBEDO * ambient_strength * ATTENUATION;
}