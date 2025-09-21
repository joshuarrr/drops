#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

// Input from Flutter
uniform sampler2D uTexture;        // The input image texture
uniform float uTime;               // Animation time (seconds)
uniform vec2 uResolution;          // Screen resolution (width, height)
uniform float uOpacity;            // Effect opacity (0.0 to 1.0)
uniform float uIntensity;          // Glitch intensity (0.0 to 1.0)
uniform float uFrequency;            // Glitch frequency (0.0 to 3.0) - controls how often glitches occur
uniform float uBlockSize;          // Block size for glitch effect (0.0 to 0.5)
uniform float uHorizontalSliceIntensity; // Horizontal slice displacement intensity (0.0 to 1.0)
uniform float uVerticalSliceIntensity;   // Vertical slice displacement intensity (0.0 to 1.0)
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
    
    // Apply slice displacement effects
    if (uHorizontalSliceIntensity > 0.0) {
        // Create time-based slice occurrence using frequency
        // Scale frequency for longer animations (30s+) - balanced approach
        float sliceTime = uTime * uFrequency * 0.3;
        
        // Create horizontal slice pattern - slices are horizontal lines
        float sliceY = floor(uv.y * 20.0); // Create 20 horizontal slices
        float sliceHash = fract(sin(sliceY * 12.9898) * 43758.5453);
        
        // Create time-based slice trigger - use fract to create repeating pattern
        // This is more robust to time discontinuities than sine waves
        float sliceTrigger = fract(sliceTime);
        float sliceProbability = smoothstep(0.0, 0.2, sliceTrigger);
        
        // Slice displacement occurs when both time-based trigger and position-based hash conditions are met
        if (sliceProbability > 0.0 && sliceHash < uHorizontalSliceIntensity) {
            // Create erratic timing for displacement
            float erraticTime = uTime + sin(uTime * 7.3) * 0.5 + cos(uTime * 11.7) * 0.3;
            float verticalDisplacement = (fract(sin(sliceY * 78.233 + erraticTime * 3.0) * 43758.5453) - 0.5) * 0.1 * uHorizontalSliceIntensity;
            
            // Apply displacement
            vec2 sliceUV = uv + vec2(0.0, verticalDisplacement);
            sliceUV = clamp(sliceUV, 0.0, 1.0); // Clamp to valid UV range
            
            // Sample with slice displacement
            vec4 sliceColor = texture(uTexture, sliceUV);
            result = mix(result, sliceColor.rgb, uHorizontalSliceIntensity * 0.9);
        }
    }
    
    if (uVerticalSliceIntensity > 0.0) {
        // Create time-based slice occurrence using frequency
        // Scale frequency for longer animations (30s+) - balanced approach
        float sliceTime = uTime * uFrequency * 0.3;
        
        // Create vertical slice pattern - slices are vertical lines
        float sliceX = floor(uv.x * 20.0); // Create 20 vertical slices
        float sliceHash = fract(sin(sliceX * 12.9898) * 43758.5453);
        
        // Create time-based slice trigger - use fract to create repeating pattern
        // This is more robust to time discontinuities than sine waves
        float sliceTrigger = fract(sliceTime);
        float sliceProbability = smoothstep(0.0, 0.2, sliceTrigger);
        
        // Slice displacement occurs when both time-based trigger and position-based hash conditions are met
        if (sliceProbability > 0.0 && sliceHash < uVerticalSliceIntensity) {
            // Create erratic timing for displacement
            float erraticTime = uTime + sin(uTime * 5.7) * 0.4 + cos(uTime * 13.2) * 0.6;
            float horizontalDisplacement = (fract(sin(sliceX * 78.233 + erraticTime * 3.5) * 43758.5453) - 0.5) * 0.1 * uVerticalSliceIntensity;
            
            // Apply displacement
            vec2 sliceUV = uv + vec2(horizontalDisplacement, 0.0);
            sliceUV = clamp(sliceUV, 0.0, 1.0); // Clamp to valid UV range
            
            // Sample with slice displacement
            vec4 sliceColor = texture(uTexture, sliceUV);
            result = mix(result, sliceColor.rgb, uVerticalSliceIntensity * 0.9);
        }
    }
    
    // Apply chromatic aberration glitch effect based on intensity
    if (uIntensity > 0.0) {
        // Create time-based glitch occurrence using frequency
        // Scale frequency for longer animations (30s+) - balanced approach
        float glitchTime = uTime * uFrequency * 0.3;
        
        // Create block-based glitch pattern
        vec2 blockUV = floor(uv / uBlockSize) * uBlockSize;
        float blockHash = fract(sin(dot(blockUV, vec2(12.9898, 78.233))) * 43758.5453);
        
        // Create time-based glitch trigger - use fract to create repeating pattern
        // This is more robust to time discontinuities than sine waves
        float glitchTrigger = fract(glitchTime);
        float glitchProbability = smoothstep(0.0, 0.2, glitchTrigger);
        
        // Glitch occurs when both time-based trigger and position-based hash conditions are met
        if (glitchProbability > 0.0 && blockHash < uIntensity) {
            // Create erratic displacement based on time and position
            float erraticTime = uTime + sin(uTime * 9.1) * 0.7 + cos(uTime * 15.3) * 0.4;
            float displacement = sin(erraticTime * 10.0 + blockHash * 6.28) * 0.1 * uIntensity;
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
