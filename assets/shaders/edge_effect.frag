#version 320 es

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform sampler2D uTexture;
uniform float uTime;
uniform vec2 uResolution;
uniform float uOpacity;
uniform float uEdgeIntensity;
uniform float uEdgeThickness;
uniform float uEdgeColor;
uniform float uIsTextContent;

out vec4 fragColor;

// Calculate intensity of a color
float intensity(in vec4 color) {
    return sqrt((color.x * color.x) + (color.y * color.y) + (color.z * color.z));
}

// Sobel filter implementation
vec3 sobel(float stepx, float stepy, vec2 center) {
    // Get samples around pixel
    float tleft = intensity(texture(uTexture, center + vec2(-stepx, stepy)));
    float left = intensity(texture(uTexture, center + vec2(-stepx, 0.0)));
    float bleft = intensity(texture(uTexture, center + vec2(-stepx, -stepy)));
    float top = intensity(texture(uTexture, center + vec2(0.0, stepy)));
    float bottom = intensity(texture(uTexture, center + vec2(0.0, -stepy)));
    float tright = intensity(texture(uTexture, center + vec2(stepx, stepy)));
    float right = intensity(texture(uTexture, center + vec2(stepx, 0.0)));
    float bright = intensity(texture(uTexture, center + vec2(stepx, -stepy)));
    
    // Sobel masks
    float x = tleft + 2.0 * left + bleft - tright - 2.0 * right - bright;
    float y = -tleft - 2.0 * top - tright + bleft + 2.0 * bottom + bright;
    float color = sqrt((x * x) + (y * y));
    
    return vec3(color, color, color);
}

void main() {
    vec2 fragCoord = FlutterFragCoord();
    vec2 uv = fragCoord / uResolution.xy;
    
    // Get the original color
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
    
    // Calculate step size based on edge thickness
    float step = max(1.0, uEdgeThickness);
    float stepx = step / uResolution.x;
    float stepy = step / uResolution.y;
    
    // Apply Sobel filter
    vec3 edgeColor = sobel(stepx, stepy, uv);
    
    // Apply intensity factor
    edgeColor *= uEdgeIntensity;
    
    // Determine final edge color based on uEdgeColor parameter
    vec3 finalEdgeColor;
    if (uEdgeColor < 0.33) {
        // Black edges - use inverted edge detection for visibility
        finalEdgeColor = vec3(1.0) - edgeColor;
    } else if (uEdgeColor < 0.67) {
        // Original color edges with edge intensity
        finalEdgeColor = color.rgb * edgeColor;
    } else {
        // White edges
        finalEdgeColor = edgeColor;
    }
    
    // Mix original image with edge detection based on opacity
    vec3 result = mix(color.rgb, finalEdgeColor, uOpacity);
    
    // Output final color
    fragColor = vec4(result, color.a);
}
