#version 460 core
precision highp float;

#include <flutter/runtime_effect.glsl>

// Texture samplers
uniform sampler2D iImage; // Input image

// Screen dimensions and time
uniform float iWidth;     // Screen width
uniform float iHeight;    // Screen height
uniform float iTime;      // Animation time (0-1)

// Ripple effect parameters
uniform float iIntensity; // Ripple intensity
uniform float iSize;      // Ripple size (equivalent to zoom in the original)
uniform float iSpeed;     // Ripple speed
uniform float iOpacity;   // Effect opacity
uniform float iColorFactor; // Color influence

// Output
out vec4 fragColor;

// Helper functions from the shadertoy example
vec2 refl2(vec2 v) {
    return abs(2.0 * fract(v * 0.5) - 1.0);
}

float sech(float v) {
    return 2.0 / (exp(v) + exp(-v));
}

float easeout(float v) {
    return (0.5 + 0.5 * cos(fract(v) * 3.1415926));
}

float wave(float x, float k, float c, float t) {
    float X = x - c * t;
    return sin(k * X) * exp(-X * X);
}

float dispersion(float d, float t) {
    float A = 0.8 * iIntensity; // Apply intensity factor
    float sum = 0.0;
    for (float k = 1.0; k < 10.0; k++) {
        sum += A * wave(abs(d), k, sqrt(k), t) / k; // dispersion for capillary waves
    }
    return sum / d; // correct 2d function ("1/r")
}

// Generate a pseudorandom value based on a 2D position
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Generate a ripple from a single source point
float ripple(vec2 seed, vec2 pos) {
    float period = 10.0 + 10.0 * iSpeed; // Scale period with speed
    float zoom = 10.0 + 20.0 * iSize;    // Scaling factor for size
    
    // Get pseudorandom values for the source position and timing
    vec2 src = vec2(random(seed), random(seed + vec2(1.0, 1.0)));
    float offset = random(seed + vec2(2.0, 2.0));
    
    // Calculate local time for this ripple
    float localtime = iTime * iSpeed / period + offset;
    
    // Update source position over time
    src = refl2(src + floor(localtime) * vec2(random(seed + vec2(3.0, 3.0)), random(seed + vec2(4.0, 4.0))));
    
    // Calculate distance from current position to ripple source
    float d = zoom * length(pos - src);
    
    // Current phase of the ripple animation
    float t = fract(localtime) * period;
    
    // Apply dispersion function to create the wave
    float v = 5.0 * dispersion(d * 5.0, t) / d;
    
    // Apply easing function to create smooth transitions
    v *= easeout(t / period);
    
    return v;
}

// Generate multiple ripples across the surface
float ripples(vec2 pos) {
    float h = 0.0;
    
    // Add multiple ripple sources with different seed positions
    h += ripple(vec2(0.0, 0.0), pos);
    h += ripple(vec2(0.0, 0.25), pos);
    h += ripple(vec2(0.25, 0.25), pos);
    h += ripple(vec2(0.25, 0.0), pos);
    h += ripple(vec2(0.0, 0.5), pos);
    h += ripple(vec2(0.25, 0.5), pos);
    h += ripple(vec2(0.5, 0.5), pos);
    h += ripple(vec2(0.5, 0.25), pos);
    h += ripple(vec2(0.5, 0.0), pos);
    
    // Average the ripple heights
    return h / 9.0;
}

// Calculate normal vector from the ripple height field
vec3 ripples_normal(vec2 pos) {
    float d = 0.001; // Small delta for differentiation
    return normalize(vec3(
        ripples(pos - vec2(d, 0.0)) - ripples(pos + vec2(d, 0.0)),
        ripples(pos - vec2(0.0, d)) - ripples(pos + vec2(0.0, d)),
        d
    ));
}

void main() {
    // Get coordinates using Flutter's coordinate system
    vec2 fragCoord = FlutterFragCoord();
    
    // Normalized coordinates (from 0 to 1)
    vec2 uv = fragCoord/vec2(iWidth, iHeight);
    
    // Calculate ripple normals
    vec3 n = ripples_normal(uv);
    
    // Calculate distorted UV coordinates based on normal
    vec2 distortedUV = uv + n.xy * iIntensity * 0.05;
    
    // Clamp UVs to valid range to avoid sampling outside the texture
    distortedUV = clamp(distortedUV, vec2(0.0), vec2(1.0));
    
    // Sample the original texture with distorted coordinates
    vec4 originalColor = texture(iImage, distortedUV);
    
    // Add specular highlight for water effect
    float specular = pow(max(0.0, dot(n, normalize(vec3(1.0, 1.0, 1.0)))), 20.0) * iIntensity;
    
    // Mix original color with ripple effect including specular
    vec4 rippleColor = vec4(
        originalColor.rgb + vec3(specular) * 0.5, 
        originalColor.a
    );
    
    // Tint water color if color factor is applied
    if (iColorFactor > 0.0) {
        rippleColor = mix(
            rippleColor,
            vec4(
                originalColor.r * (1.0 + n.x * iColorFactor),
                originalColor.g * (1.0 + n.y * iColorFactor),
                originalColor.b * (1.0 + 0.5 * iColorFactor),
                originalColor.a
            ),
            iColorFactor
        );
    }
    
    // Final blend between original and effect
    fragColor = mix(originalColor, rippleColor, iOpacity);
} 