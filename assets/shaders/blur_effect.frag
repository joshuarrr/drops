#version 460 core

precision highp float;

// Input from Flutter - order matches uniform location in Flutter code
uniform sampler2D uTexture;
uniform float uBlurAmount;  // Controls spread distance of fragments
uniform float uBlurRadius;  // Controls size/shape of fragments
uniform vec2 uResolution;
uniform float uOpacity;    // 0-1 opacity applied to effect
uniform float uBlendMode;  // 0=normal 1=multiply 2=screen
uniform float uIntensity;  // Amplifies the intensity of shatter fragments 
uniform float uContrast;   // Increases contrast between fragments

// Define output
out vec4 fragColor;

// Apply contrast and intensity to a color
vec4 enhanceColor(vec4 color, float intensity, float contrast) {
    // Apply intensity first - increase color values while preserving alpha
    // Use a more dramatic intensity effect (ranges from 1.0 to 3.0 in the BlurSettings)
    vec3 intensified = color.rgb * intensity;
    
    // Apply contrast - make dark areas darker and light areas lighter
    // Contrast now has a more dramatic effect (ranges from 0.0 to 2.0 in the BlurSettings)
    vec3 contrasted = (intensified - 0.5) * (1.0 + contrast) + 0.5;
    
    // Return enhanced color with original alpha - keep alpha separate from intensity
    // This ensures intensity only affects color, not transparency
    return vec4(clamp(contrasted, 0.0, 1.0), color.a);
}

// Gaussian blur implementation with distinct amount/radius controls
vec4 gaussianBlur(sampler2D tex, vec2 uv, vec2 resolution, float amount, float radius) {
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
    float effectiveAmount = clamp(amount, 0.0, 1.0);
    float effectiveRadius = clamp(radius, 1.0, 120.0);
    
    // Make amount control distance of fragments (spread)
    // And radius control size/shape of fragments
    // This separates their functions more clearly
    vec2 spreadFactor = pixel * effectiveAmount * 20.0;
    float sampleRadius = max(effectiveRadius * 0.5, 1.0);
    
    // X direction (horizontal blur)
    for (int i = 1; i < 5; i++) {
        float weight = weights[i];
        float offset = float(i) * sampleRadius;
        
        // Add weighted samples in both directions
        vec2 offsetUV1 = uv + vec2(offset * spreadFactor.x, 0.0);
        vec2 offsetUV2 = uv - vec2(offset * spreadFactor.x, 0.0);
        
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
        float offset = float(i) * sampleRadius;
        
        // Add weighted samples in both directions
        vec2 offsetUV1 = uv + vec2(0.0, offset * spreadFactor.y);
        vec2 offsetUV2 = uv - vec2(0.0, offset * spreadFactor.y);
        
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
    vec2 uv = gl_FragCoord.xy / uResolution;
    
    // Sample base texture
    vec4 directSample = texture(uTexture, uv);
    
    // If effect opacity is zero or amount nearly zero, return original
    if (uOpacity <= 0.01) {
        fragColor = directSample;
        return;
    }
    
    // Apply gaussian blur (shatter effect)
    vec4 effectColor = gaussianBlur(uTexture, uv, uResolution, uBlurAmount, uBlurRadius);
    
    // Apply intensity and contrast enhancement to the blurred effect
    effectColor = enhanceColor(effectColor, uIntensity, uContrast);
    
    // For shatter effect, we need to preserve some alpha from the blur effect
    // even for pixels that were originally transparent
    float effectOpacity = uOpacity;
    
    // Only use direct sample alpha for completely invisible areas
    // This allows the blur to extend beyond the original text boundaries
    if (directSample.a < 0.01 && effectColor.a > 0.0) {
        // Apply opacity directly to the blur effect in transparent areas
        // Apply intensity to color but not to transparency
        float shatterAlpha = effectColor.a * effectOpacity * 0.8; 
        fragColor = vec4(effectColor.rgb, shatterAlpha);
        return;
    }

    vec3 base = directSample.rgb;
    vec3 blend = effectColor.rgb;
    vec3 result;
    
    // Use opacity directly as mix factor - this should control the strength of the effect
    float mixFactor = effectOpacity;
    
    if (uBlendMode < 0.5) {            // Normal
        // Standard blend mode
        result = mix(base, blend, mixFactor);
    } else if (uBlendMode < 1.5) {     // Multiply
        // Multiply darkens the image - ensure fragments appear more distinct
        vec3 multiplied = base * blend;
        // Intensify the multiplied effect by adding contrast
        multiplied = (multiplied - 0.5) * 1.2 + 0.5;
        result = mix(base, multiplied, mixFactor);
    } else if (uBlendMode < 2.5) {     // Screen
        // Screen lightens the image - intensified for more dramatic shatter effect
        vec3 screened = 1.0 - (1.0 - base) * (1.0 - blend);
        // Boost the screened effect to make it more distinct
        screened = pow(screened, vec3(0.85));
        result = mix(base, screened, mixFactor);
    } else {                           // Fallback normal
        result = mix(base, blend, mixFactor);
    }
    
    fragColor = vec4(result, directSample.a);
} 