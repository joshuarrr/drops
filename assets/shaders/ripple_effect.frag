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
uniform float iDropCount;   // Number of ripple drops (1-30)
uniform float iSeed;        // Randomization seed
uniform float iOvalness;    // Control for oval shape (0=circles, 1=very oval)
uniform float iRotation;    // Rotation angle for oval ripples (0-1, scaled to 0-2π)

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
    return sum / max(d, 0.001); // correct 2d function ("1/r"), avoid division by zero
}

// Generate a pseudorandom value based on a 2D position
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Generate seed offsets for completely random positions
vec2 getRandomOffset(float index, float seed) {
    // Use different seeds for x and y coordinates and incorporate the iSeed value
    vec2 offset;
    offset.x = random(vec2(index * 0.1 + seed, iSeed * 2.3));
    offset.y = random(vec2(iSeed * 3.7, index * 0.1 + seed));
    return offset;
}

// Calculate a drop's lifecycle state (0-1 for fade-in, 1-2 for active, 2-3 for fade-out)
float getDropLifecycle(float index, float time) {
    // Ensure each drop has a different phase in the lifecycle
    // Divide the total cycle time by dropCount to stagger the drops
    float dropCount = clamp(iDropCount, 1.0, 30.0);
    
    // Create offset for each drop that's evenly distributed across the cycle
    // plus a bit of randomization to avoid too much uniformity
    float baseOffset = index / dropCount * 3.0; // Distribute drops evenly across the 3.0 cycle
    float randomOffset = random(vec2(index * 13.37, iSeed * 42.0)) * 0.5; // Small random variation
    
    // Calculate the current lifecycle phase (0-3) with even distribution
    float cycleTime = mod(time + baseOffset + randomOffset, 3.0);
    
    return cycleTime;
}

// Calculate drop opacity based on lifecycle
float getDropOpacity(float lifecycle) {
    if (lifecycle < 1.0) {
        // Fade in (0-1)
        return smoothstep(0.0, 1.0, lifecycle);
    } else if (lifecycle < 2.0) {
        // Full opacity (1-2)
        return 1.0;
    } else {
        // Fade out (2-3)
        return smoothstep(1.0, 0.0, lifecycle - 2.0);
    }
}

// Generate a ripple from a single source point
float ripple(vec2 seed, vec2 pos, float aspectRatio, float opacity, float lifecycle) {
    float period = 10.0 + 10.0 * iSpeed; // Scale period with speed
    float zoom = 10.0 + 20.0 * iSize;    // Scaling factor for size
    
    // Get pseudorandom values for the source position and timing
    vec2 src = seed;
    float offset = random(seed + vec2(2.0, 2.0) + vec2(iSeed));
    
    // Calculate local time for this ripple - vary with lifecycle 
    // Use lifecycle to control ring expansion (0-3 range maps to animation progress)
    // For a new drop (lifecycle < 1), the ripple animation starts from the beginning
    float waveProgress = min(lifecycle, 2.0) / 2.0; // Map 0-2 to 0-1 range (caps at 1.0)
    float localtime = waveProgress * iSpeed / period + offset;
    
    // Create minor movements over time
    vec2 timeDrift = vec2(
        sin(localtime * 1.5 + seed.x * 10.0 + iSeed),
        cos(localtime * 1.2 + seed.y * 10.0 + iSeed)
    ) * 0.03;
    
    src += timeDrift;
    
    // Calculate displacement vector from source to current position
    float dx = pos.x - src.x;
    float dy = pos.y - src.y;
    
    // Calculate rotation angle (scale from 0-1 to 0-2π)
    float rotationAngle = iRotation * 6.28318530718; // 2π
    
    // First, correct for the screen's aspect ratio to make circles perfect
    // This ensures that when ovalness=0, we have perfect circles
    dx *= aspectRatio;
    
    // Now apply the ovalness - at maximum ovalness (1.0), we create ellipses
    // We'll use rotation value to determine if horizontal (0.25/0.75) or vertical (0/0.5) ovals
    if (iOvalness > 0.0) {
        // Calculate a stretch factor: more ovalness = more stretch
        float stretchFactor = 1.0 + iOvalness * 2.0; // Scale up for more dramatic effect
        
        // Rotate the point according to the rotation parameter
        float sinAngle = sin(rotationAngle);
        float cosAngle = cos(rotationAngle);
        
        // First rotate
        float rotatedDx = dx * cosAngle - dy * sinAngle;
        float rotatedDy = dx * sinAngle + dy * cosAngle;
        
        // Then apply stretching - make x-coordinate wider (horizontal oval)
        rotatedDx /= stretchFactor;
        
        // Rotate back to apply the stretching in the right orientation
        dx = rotatedDx * cosAngle + rotatedDy * sinAngle;
        dy = -rotatedDx * sinAngle + rotatedDy * cosAngle;
    }
    
    // Calculate distance with the modified coordinates
    float d = zoom * sqrt(dx * dx + dy * dy);
    
    // Current phase of the ripple animation - scaled by lifecycle
    float t = waveProgress * period;
    
    // Apply dispersion function to create the wave
    float v = 5.0 * dispersion(d * 5.0, t) / max(d, 0.001);
    
    // Apply easing function to create smooth transitions
    v *= easeout(t / period);
    
    // Apply opacity based on drop lifecycle
    v *= opacity;
    
    // Fade out as the ripple approaches the end of its lifecycle
    if (lifecycle > 2.0) {
        float fadeOut = smoothstep(1.0, 0.0, (lifecycle - 2.0));
        v *= fadeOut;
    }
    
    return v;
}

// Generate multiple ripples across the surface with random positions
float ripples(vec2 pos) {
    // Calculate aspect ratio for proper circular ripples
    // Width divided by height gives us the correction factor for x coordinates
    float aspectRatio = iWidth / iHeight;
    
    float h = 0.0;
    int dropCount = int(clamp(iDropCount, 1.0, 30.0));
    
    // Use completely randomized positions with animated lifecycle
    for (int i = 0; i < dropCount; i++) {
        // Calculate drop lifecycle
        float lifecycle = getDropLifecycle(float(i), iTime);
        float opacity = getDropOpacity(lifecycle);
        
        // Use a unique seed for each drop based on its index
        // This ensures each drop has a consistent but unique position
        float seedBase = float(i) * 100.0 + iSeed;
        
        // Get completely random positions across the entire screen
        // Each drop should have its own position that doesn't change during its lifecycle
        vec2 dropPosition = getRandomOffset(float(i), seedBase);
        
        // Apply the ripple effect for this drop
        h += ripple(dropPosition, pos, aspectRatio, opacity, lifecycle);
    }
    
    // Average the ripple heights and scale by intensity
    return h / float(dropCount);
}

// Calculate normal vector from the ripple height field
vec3 ripples_normal(vec2 pos) {
    float d = 0.001; // Small delta for differentiation
    return normalize(vec3(
        ripples(pos - vec2(d, 0.0)) - ripples(pos + vec2(d, 0.0)),
        ripples(pos - vec2(0.0, d)) - ripples(pos + vec2(0.0, d)),
        d * 2.0 * iIntensity // Add intensity to the z component for stronger normals
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