#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

// Input from Flutter
uniform sampler2D uTexture;        // The input image texture
uniform float uTime;               // Animation time (seconds)
uniform vec2 uResolution;          // Screen resolution (width, height)
uniform float uOpacity;            // Effect opacity (0.0 to 1.0)
uniform float uIntensity;          // Glitch intensity (0.0 to 1.0)
uniform float uSpeed;              // Effect speed multiplier (0.0 to 3.0)
uniform float uBlockSize;          // Block size for glitch effect (0.0 to 0.5)
uniform float uIsTextContent;      // Flag for text content (1.0 = text)

// Define output
out vec4 fragColor;

void main() {
    // CRITICAL: Get the fragment coordinate using Flutter's helper function
    // This is essential for proper coordinate handling in Flutter
    vec2 fragCoord = FlutterFragCoord();
    
    // Normalized pixel coordinates (from 0 to 1)
    // This creates proper UV coordinates for texture sampling
    vec2 uv = fragCoord/uResolution.xy;
    
    // Sample the texture
    vec4 color = texture(uTexture, uv);
    
    // Skip processing for transparent pixels
    if (color.a < 0.01) {
        fragColor = color;
        return;
    }
    
    // Skip processing for text content if needed
    if (uIsTextContent > 0.5) {
        fragColor = color;
        return;
    }
    
    // Glitch effect implementation
    vec3 result = color.rgb;
    
    // Apply glitch effect based on intensity
    if (uIntensity > 0.0) {
        // Calculate glitch timing based on speed
        float glitchTime = uTime * uSpeed;
        
        // Create block-based glitch pattern
        vec2 blockUV = floor(uv / uBlockSize) * uBlockSize;
        float blockHash = fract(sin(dot(blockUV, vec2(12.9898, 78.233))) * 43758.5453);
        
        // Glitch occurs when block hash is below intensity threshold
        if (blockHash < uIntensity) {
            // Horizontal displacement
            float displacement = sin(glitchTime * 10.0 + blockHash * 6.28) * 0.1 * uIntensity;
            vec2 glitchUV = uv + vec2(displacement, 0.0);
            
            // Sample with displacement
            vec4 glitchColor = texture(uTexture, glitchUV);
            
            // Mix original and glitched colors
            result = mix(result, glitchColor.rgb, uIntensity * 0.8);
            
            // Add color channel separation for more glitch effect
            if (uIntensity > 0.5) {
                vec2 redUV = uv + vec2(displacement * 0.5, 0.0);
                vec2 blueUV = uv + vec2(-displacement * 0.3, 0.0);
                
                float red = texture(uTexture, redUV).r;
                float green = texture(uTexture, uv).g;
                float blue = texture(uTexture, blueUV).b;
                
                result = mix(result, vec3(red, green, blue), (uIntensity - 0.5) * 2.0);
            }
        }
    }
    
    // Apply opacity to blend the effect
    result = mix(color.rgb, result, uOpacity);
    
    // Output the final color
    fragColor = vec4(result, color.a);
}
