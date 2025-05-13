#version 460 core

precision highp float;

// Input from Flutter - order matches uniform location in Flutter code
uniform sampler2D uTexture;
uniform float uBlurAmount;
uniform float uBlurRadius;
uniform vec2 uResolution;
uniform float uOpacity; // 0-1 opacity applied to effect
uniform float uFacets; // number of facet divisions
uniform float uBlendMode; // 0=normal 1=multiply 2=screen

// Define output
out vec4 fragColor;

// Gaussian blur implementation
vec4 gaussianBlur(sampler2D tex, vec2 uv, vec2 resolution, float strength, float radius) {
    // Calculate pixel size
    vec2 pixel = 1.0 / resolution;
    
    // Always use best quality (1.0)
    float quality = 1.0;
    
    // Sample contribution weights (Gaussian approximation)
    float weights[5];
    weights[0] = 0.227027;
    weights[1] = 0.1945946;
    weights[2] = 0.1216216;
    weights[3] = 0.054054;
    weights[4] = 0.016216;
    
    // Start with central texel
    vec4 color = texture(tex, uv) * weights[0];
    float totalWeight = weights[0];
    
    // Ensure blur parameters stay within safe ranges
    // Both amount and radius need proper clamping
    float effectiveStrength = clamp(strength, 0.0, 1.0);
    float effectiveRadius = clamp(radius, 1.0, 60.0);
    
    // Calculate sampling step size with better scaling
    // Use a more conservative scale factor for visual effect
    vec2 step = pixel * effectiveRadius * effectiveStrength * 5.0;
    
    // X direction (horizontal blur)
    for (int i = 1; i < 5; i++) {
        float weight = weights[i];
        float offset = float(i);
        
        // Add weighted samples in both directions
        vec2 offsetUV1 = uv + vec2(offset * step.x, 0.0);
        vec2 offsetUV2 = uv - vec2(offset * step.x, 0.0);
        
        // Ensure texture coordinates stay within bounds
        offsetUV1 = clamp(offsetUV1, vec2(0.0), vec2(1.0));
        offsetUV2 = clamp(offsetUV2, vec2(0.0), vec2(1.0));
        
        color += texture(tex, offsetUV1) * weight;
        color += texture(tex, offsetUV2) * weight;
        totalWeight += weight * 2.0;
    }
    
    // Y direction (vertical blur)
    for (int i = 1; i < 5; i++) {
        float weight = weights[i];
        float offset = float(i);
        
        // Add weighted samples in both directions
        vec2 offsetUV1 = uv + vec2(0.0, offset * step.y);
        vec2 offsetUV2 = uv - vec2(0.0, offset * step.y);
        
        // Ensure texture coordinates stay within bounds
        offsetUV1 = clamp(offsetUV1, vec2(0.0), vec2(1.0));
        offsetUV2 = clamp(offsetUV2, vec2(0.0), vec2(1.0));
        
        color += texture(tex, offsetUV1) * weight;
        color += texture(tex, offsetUV2) * weight;
        totalWeight += weight * 2.0;
    }
    
    // Normalize color by total weight
    return color / totalWeight;
}

void main() {
    // Convert from pixel coordinates to 0-1 UV coordinates
    vec2 originalUV = gl_FragCoord.xy / uResolution;
    vec2 uv = originalUV;
    
    // Apply faceting by snapping UVs to a grid when uFacets > 1
    float facetCount = max(1.0, uFacets);
    if (facetCount > 1.0) {
        vec2 grid = vec2(facetCount);
        uv = (floor(uv * grid) + 0.5) / grid;
    }
    
    // Sample base texture at original UV (no faceting)
    vec4 directSample = texture(uTexture, originalUV);
    
    // If texture sampling failed completely, show a bright color
    if (directSample.a == 0.0) {
        fragColor = vec4(1.0, 0.0, 0.0, 1.0); // Bright red for debugging
        return;
    }
    
    // If effect opacity is zero or amount nearly zero, return original
    if (uOpacity <= 0.01 || uBlurAmount <= 0.01) {
        fragColor = directSample;
        return;
    }
    
    // Apply gaussian blur (shatter effect) using possibly faceted UVs
    vec4 effectColor = gaussianBlur(uTexture, uv, uResolution, uBlurAmount, uBlurRadius);
    
    // Blend with base according to selected blend mode
    vec3 base = directSample.rgb;
    vec3 blend = effectColor.rgb;
    vec3 result;
    
    if (uBlendMode < 0.5) {            // Normal
        result = mix(base, blend, uOpacity);
    } else if (uBlendMode < 1.5) {     // Multiply
        result = mix(base, base * blend, uOpacity);
    } else if (uBlendMode < 2.5) {     // Screen
        result = mix(base, 1.0 - (1.0 - base) * (1.0 - blend), uOpacity);
    } else {                           // Fallback normal
        result = mix(base, blend, uOpacity);
    }
    
    fragColor = vec4(result, directSample.a);
} 