#version 460 core

precision highp float;

// Input from Flutter
uniform sampler2D uTexture;
uniform vec2 uResolution;

// Blur parameters
uniform float uBlurAmount;
uniform float uBlurQuality;

// Define output
out vec4 fragColor;

// Gaussian blur implementation
vec4 gaussianBlur(sampler2D tex, vec2 uv, vec2 resolution, float strength) {
    // Calculate pixel size
    vec2 pixel = 1.0 / resolution;
    
    // Adjust blur quality (1.0 = best quality, more samples)
    float quality = max(1.0, 8.0 * (1.0 - uBlurQuality));
    
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
    
    // Adjust step based on strength and quality
    vec2 step = pixel * strength * 2.0;
    
    // X direction (horizontal blur)
    for (int i = 1; i < 5; i++) {
        float weight = weights[i];
        float offset = float(i) * quality;
        
        // Add weighted samples in both directions
        color += texture(tex, uv + vec2(offset * step.x, 0.0)) * weight;
        color += texture(tex, uv - vec2(offset * step.x, 0.0)) * weight;
        totalWeight += weight * 2.0;
    }
    
    // Y direction (vertical blur)
    for (int i = 1; i < 5; i++) {
        float weight = weights[i];
        float offset = float(i) * quality;
        
        // Add weighted samples in both directions
        color += texture(tex, uv + vec2(0.0, offset * step.y)) * weight;
        color += texture(tex, uv - vec2(0.0, offset * step.y)) * weight;
        totalWeight += weight * 2.0;
    }
    
    // Normalize color by total weight
    return color / totalWeight;
}

void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;
    
    // Skip blur processing if amount is 0
    if (uBlurAmount <= 0.01) {
        fragColor = texture(uTexture, uv);
        return;
    }
    
    // Scale blur amount for better control (0-1 range to 0-20 range)
    float blurStrength = uBlurAmount * 15.0;
    
    // Apply gaussian blur
    fragColor = gaussianBlur(uTexture, uv, uResolution, blurStrength);
} 