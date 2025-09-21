#version 460 core

precision highp float;

// Input from Flutter
uniform sampler2D uTexture;    // Main texture to be distorted
uniform sampler2D uNoiseTexture; // Noise texture for random values
uniform float uTime;
uniform float uResolution; // aspect ratio
uniform float uRainIntensity; // Controls number of drops (0-1)
uniform float uDropSize; // Controls size of droplets (0-1, scaled internally)
uniform float uFallSpeed; // Controls speed of falling drops (0-1)
uniform float uRefraction; // Controls visual distortion from drops (0-1)
uniform float uTrailIntensity; // Controls length/opacity of trails behind drops (0-1)
uniform float uIsAnimated; // Flag indicating if animation is enabled (1.0) or disabled (0.0)

// Define output
out vec4 fragColor;

// Smoothstep helper
#define S(a, b, t) smoothstep(a, b, t)

// Random functions (from reference)
vec3 N13(float p) {
    vec3 p3 = fract(vec3(p) * vec3(.1031,.11369,.13787));
    p3 += dot(p3, p3.yzx + 19.19);
    return fract(vec3((p3.x + p3.y)*p3.z, (p3.x+p3.z)*p3.y, (p3.y+p3.z)*p3.x));
}

float N(float t) {
    return fract(sin(t*12345.564)*7658.76);
}

float Saw(float b, float t) {
    return S(0., b, t)*S(1., b, t);
}

// Drop layer function (adapted from reference)
vec2 DropLayer(vec2 uv, float t) {
    vec2 UV = uv;
    
    // Make drops fall
    uv.y += t * (0.2 + uFallSpeed * 0.8);
    
    // Grid setup - adjust based on drop size
    float gridScale = 0.015 * (0.2 + uDropSize * 1.8);
    vec2 a = vec2(6., 1.) * gridScale * 100.0; // Scale to screen
    vec2 grid = a * 2.;
    vec2 id = floor(uv * grid);
    
    // Column shift for variety
    float colShift = N(id.x); 
    uv.y += colShift;
    
    id = floor(uv * grid);
    vec3 n = N13(id.x * 35.2 + id.y * 2376.1);
    vec2 st = fract(uv * grid) - vec2(.5, 0);
    
    float x = n.x - .5;
    
    // Wiggle effect
    float y = UV.y * 20.;
    float wiggle = sin(y + sin(y));
    x += wiggle * (.5 - abs(x)) * (n.z - .5);
    x *= .7;
    
    // Drop timing
    float ti = fract(t + n.z);
    y = (Saw(.85, ti) - .5) * .9 + .5;
    vec2 p = vec2(x, y);
    
    // Distance to drop
    float d = length((st - p) * a.yx);
    
    // Main drop
    float mainDrop = S(.4, .0, d);
    
    // Trail calculation
    float r = sqrt(S(1., y, st.y));
    float cd = abs(st.x - x);
    float trail = S(.23 * r, .15 * r * r, cd);
    float trailFront = S(-.02, .02, st.y - y);
    trail *= trailFront * r * r;
    
    // Droplets
    y = UV.y;
    float trail2 = S(.2 * r, .0, cd);
    float droplets = max(0., (sin(y * (1. - y) * 120.) - st.y)) * trail2 * trailFront * n.z;
    y = fract(y * 10.) + (st.y - .5);
    float dd = length(st - vec2(x, y));
    droplets = S(.3, 0., dd);
    
    float m = mainDrop + droplets * r * trailFront;
    
    return vec2(m, trail);
}

// Static drops function
float StaticDrops(vec2 uv, float t) {
    uv *= 40.;
    
    vec2 id = floor(uv);
    uv = fract(uv) - .5;
    vec3 n = N13(id.x * 107.45 + id.y * 3543.654);
    vec2 p = (n.xy - .5) * .7;
    float d = length(uv - p);
    
    float fade = Saw(.025, fract(t + n.z));
    float c = S(.3, 0., d) * fract(n.z * 10.) * fade;
    return c;
}

// Main drops function
vec2 Drops(vec2 uv, float t, float l0, float l1, float l2) {
    float s = StaticDrops(uv, t) * l0; 
    vec2 m1 = DropLayer(uv, t) * l1;
    vec2 m2 = DropLayer(uv * 1.85, t) * l2;
    
    float c = s + m1.x + m2.x;
    c = S(.3, 1., c);
    
    return vec2(c, max(m1.y * l0, m2.y * l1));
}

void main() {
    // Get normalized screen coordinates
    vec2 uv = gl_FragCoord.xy / vec2(textureSize(uTexture, 0));
    vec2 UV = uv;
    
    // Calculate effective time for animation
    float effectiveTime;
    if (uIsAnimated > 0.5) {
        effectiveTime = uTime * (0.2 + uFallSpeed * 0.8);
    } else {
        effectiveTime = 0.0;
    }
    
    float t = effectiveTime * 0.2;
    
    // Rain amount based on intensity
    float rainAmount = uRainIntensity;
    
    // Blur settings
    float maxBlur = mix(3., 6., rainAmount);
    float minBlur = 2.;
    
    // Layer intensities
    float staticDrops = S(-.5, 1., rainAmount) * 2.;
    float layer1 = S(.25, .75, rainAmount);
    float layer2 = S(.0, .5, rainAmount);
    
    // Calculate drops
    vec2 c = Drops(uv, t, staticDrops, layer1, layer2);
    
    // Calculate normals for texture distortion
    vec2 e = vec2(.001, 0.);
    float cx = Drops(uv + e, t, staticDrops, layer1, layer2).x;
    float cy = Drops(uv + e.yx, t, staticDrops, layer1, layer2).x;
    vec2 n = vec2(cx - c.x, cy - c.x);
    
    // Apply refraction distortion
    n *= uRefraction;
    
    // Calculate focus blur based on drop intensity
    float focus = mix(maxBlur - c.y, minBlur, S(.1, .2, c.x));
    
    // Sample texture with distortion (no LOD support in Flutter)
    vec3 col = texture(uTexture, UV + n).rgb;
    
    // Apply trail intensity
    col *= mix(1.0, 1.0 - c.y * 0.3, uTrailIntensity);
    
    fragColor = vec4(col, 1.);
}