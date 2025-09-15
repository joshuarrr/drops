#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

// Input from Flutter
uniform sampler2D uTexture;
uniform float uTime;
uniform vec2 uResolution;
uniform float uOpacity;
uniform float uImageOpacity;  // Opacity of the underlying image
uniform float uHatchYOffset;
uniform float uLumThreshold1;
uniform float uLumThreshold2;
uniform float uLumThreshold3;
uniform float uLumThreshold4;
uniform float uLineSpacing;
uniform float uLineThickness;
uniform float uIsTextContent;

// Define output
out vec4 fragColor;

void main() {
    // Get the fragment coordinate using Flutter's helper function
    vec2 fragCoord = FlutterFragCoord();
    
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord/uResolution.xy;
    
    // Sample the texture
    vec4 color = texture(uTexture, uv);
    
    // Skip processing for transparent pixels
    if (color.a < 0.01) {
        fragColor = color;
        return;
    }
    
    // Skip processing for text content
    if (uIsTextContent > 0.5) {
        fragColor = color;
        return;
    }
    
    // Calculate luminance
    float lum = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    
    // Calculate spacing and thickness based on screen resolution
    float scale = min(uResolution.x, uResolution.y) / 800.0;
    float spacing = max(1.0, uLineSpacing * scale);
    float thickness = max(0.5, uLineThickness * scale);
    float offset = uHatchYOffset;
    
    // Animation is now handled by the animation state manager in Dart code
    // We keep uTime for compatibility but don't use it directly
    
    // Start with white background
    vec3 baseColor = vec3(1.0);
    
    // Apply image with its opacity
    baseColor = mix(baseColor, color.rgb, uImageOpacity);
    
    // Create a copy of the base color for sketch effect
    vec3 sketchColor = baseColor;
    
    // Apply crosshatching based on luminance thresholds
    // Layer 1: Diagonal lines (top-left to bottom-right)
    if (lum < uLumThreshold1) {
        float hatch1 = mod(fragCoord.x + fragCoord.y + offset, spacing);
        if (hatch1 < thickness) {
            sketchColor *= 0.3; // Darken for line effect
        }
    }
    
    // Layer 2: Diagonal lines (top-right to bottom-left)
    if (lum < uLumThreshold2) {
        float hatch2 = mod(fragCoord.x - fragCoord.y - offset, spacing);
        if (hatch2 < thickness) {
            sketchColor *= 0.3; // Darken for line effect
        }
    }
    
    // Layer 3: Horizontal lines
    if (lum < uLumThreshold3) {
        float hatch3 = mod(fragCoord.y + offset * 0.5, spacing);
        if (hatch3 < thickness) {
            sketchColor *= 0.3; // Darken for line effect
        }
    }
    
    // Layer 4: Vertical lines (darkest areas)
    if (lum < uLumThreshold4) {
        float hatch4 = mod(fragCoord.x - offset * 0.5, spacing);
        if (hatch4 < thickness) {
            sketchColor *= 0.3; // Darken for line effect
        }
    }
    
    // Apply sketch effect with its own opacity
    vec3 result = mix(baseColor, sketchColor, uOpacity);
    
    fragColor = vec4(result, color.a);
}