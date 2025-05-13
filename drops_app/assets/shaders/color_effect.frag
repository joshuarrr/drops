#version 460 core

precision highp float;

// Input from Flutter
uniform sampler2D uTexture;
uniform float uTime;
uniform float uHue;
uniform float uSaturation;
uniform float uLightness;
uniform float uOverlayHue;
uniform float uOverlayIntensity;
uniform float uOverlayOpacity;
uniform vec2 uResolution;

// Define output
out vec4 fragColor;

// Helper functions for HSL color manipulation
vec3 rgb2hsl(vec3 rgb) {
    float maxval = max(rgb.r, max(rgb.g, rgb.b));
    float minval = min(rgb.r, min(rgb.g, rgb.b));
    float delta = maxval - minval;
    
    vec3 hsl = vec3(0.0, 0.0, (maxval + minval) / 2.0);
    
    if (delta != 0.0) {
        hsl.y = hsl.z < 0.5 ? delta / (maxval + minval) : delta / (2.0 - maxval - minval);
        
        if (rgb.r == maxval) {
            hsl.x = (rgb.g - rgb.b) / delta + (rgb.g < rgb.b ? 6.0 : 0.0);
        } else if (rgb.g == maxval) {
            hsl.x = (rgb.b - rgb.r) / delta + 2.0;
        } else {
            hsl.x = (rgb.r - rgb.g) / delta + 4.0;
        }
        
        hsl.x /= 6.0;
    }
    
    return hsl;
}

float hueToRgb(float p, float q, float t) {
    if (t < 0.0) t += 1.0;
    if (t > 1.0) t -= 1.0;
    if (t < 1.0/6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0/2.0) return q;
    if (t < 2.0/3.0) return p + (q - p) * (2.0/3.0 - t) * 6.0;
    return p;
}

vec3 hsl2rgb(vec3 hsl) {
    if (hsl.y == 0.0) return vec3(hsl.z);
    
    float q = hsl.z < 0.5 ? hsl.z * (1.0 + hsl.y) : hsl.z + hsl.y - hsl.z * hsl.y;
    float p = 2.0 * hsl.z - q;
    
    vec3 rgb;
    float h = hsl.x;
    
    float t1 = fract(h + 1.0/3.0);
    float t2 = fract(h);
    float t3 = fract(h - 1.0/3.0);
    
    rgb.r = hueToRgb(p, q, t1);
    rgb.g = hueToRgb(p, q, t2);
    rgb.b = hueToRgb(p, q, t3);
    
    return rgb;
}

// Main fragment shader function
void main() {
    vec2 uv = gl_FragCoord.xy / uResolution;
    
    // Sample the texture
    vec4 color = texture(uTexture, uv);
    
    // If texture sampling failed, use a default color to make it obvious
    if (color.a == 0.0) {
        fragColor = vec4(1.0, 0.0, 1.0, 1.0); // Bright magenta for debugging
        return;
    }
    
    // Convert to HSL for easier manipulation
    vec3 hsl = rgb2hsl(color.rgb);
    
    // Apply hue, saturation, and lightness adjustments
    hsl.x = fract(hsl.x + uHue); // Hue adjustment
    hsl.y = clamp(hsl.y * (1.0 + uSaturation), 0.0, 1.0); // Saturation adjustment
    hsl.z = clamp(hsl.z * (1.0 + uLightness), 0.0, 1.0); // Lightness adjustment
    
    // Convert back to RGB
    vec3 adjustedRgb = hsl2rgb(hsl);
    
    // Apply overlay if intensity and opacity are > 0
    if (uOverlayOpacity > 0.0 && uOverlayIntensity > 0.0) {
        // Create base overlay color from hue
        vec3 overlayHsl = vec3(uOverlayHue, 1.0, 0.5);
        vec3 overlayRgb = hsl2rgb(overlayHsl);
        
        // Apply overlay with opacity
        float overlayAmount = uOverlayOpacity * uOverlayIntensity;
        adjustedRgb = mix(adjustedRgb, overlayRgb, overlayAmount);
        
        // Add rainbow effect if intensity is high
        if (uOverlayIntensity > 0.5) {
            vec3 rainbowHsl = vec3(fract(uv.y + uTime * 0.1), 0.8, 0.5);
            vec3 rainbowRgb = hsl2rgb(rainbowHsl);
            adjustedRgb = mix(adjustedRgb, rainbowRgb, 0.2 * (uOverlayIntensity - 0.5) * 2.0);
        }
    }
    
    fragColor = vec4(adjustedRgb, color.a);
} 