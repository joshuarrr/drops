#version 460 core

precision highp float;

// Texture sampler
uniform sampler2D iTexture;

// Canvas size
uniform float iWidth;
uniform float iHeight;

// Time and animation
uniform float iTime;

// Cymatics parameters
uniform float intensity;
uniform float frequency;
uniform float amplitude;
uniform float complexity;
uniform float speed;
uniform float colorIntensity;

// Audio reactivity
uniform float audioReactive;  // 0.0 = disabled, 1.0 = enabled
uniform float audioSensitivity;

// Audio analysis data from music player
uniform float bassLevel;     // Low frequency intensity (0.0-1.0)
uniform float midLevel;      // Mid frequency intensity (0.0-1.0)
uniform float trebleLevel;   // High frequency intensity (0.0-1.0)

// Background color (new)
uniform float bgHue;         // Background hue (0.0-1.0)
uniform float bgSaturation;  // Background saturation (0.0-1.0)
uniform float bgLightness;   // Background lightness (0.0-1.0)

// Constants
const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;

// Convert HSL to RGB
vec3 hslToRgb(float h, float s, float l) {
    float r, g, b;
    
    if (s == 0.0) {
        r = g = b = l; // achromatic
    } else {
        float q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
        float p = 2.0 * l - q;
        r = hueToRgb(p, q, h + 1.0/3.0);
        g = hueToRgb(p, q, h);
        b = hueToRgb(p, q, h - 1.0/3.0);
    }
    
    return vec3(r, g, b);
}

float hueToRgb(float p, float q, float t) {
    if (t < 0.0) t += 1.0;
    if (t > 1.0) t -= 1.0;
    if (t < 1.0/6.0) return p + (q - p) * 6.0 * t;
    if (t < 1.0/2.0) return q;
    if (t < 2.0/3.0) return p + (q - p) * (2.0/3.0 - t) * 6.0;
    return p;
}

// Generate cymatics pattern
float generateCymaticsPattern(vec2 uv, float time) {
    // Scale frequencies to have more impact
    float bassIntensity = bassLevel * audioSensitivity * 2.0;
    float midIntensity = midLevel * audioSensitivity * 1.5;
    float trebleIntensity = trebleLevel * audioSensitivity;
    
    // Base movement speed affected by audio
    float timeScale = time * speed * (1.0 + bassIntensity * 0.5);
    
    // Center coordinates
    vec2 center = vec2(0.5, 0.5);
    vec2 pos = uv - center;
    
    // Calculate distance from center
    float dist = length(pos);
    
    // Angle from center
    float angle = atan(pos.y, pos.x);
    
    // Create base pattern using sin waves
    float pattern = 0.0;
    
    // Add multiple frequencies with varying phases
    // Base waves - low frequencies
    pattern += sin(dist * frequency * 20.0 * (1.0 + bassIntensity) - timeScale) * amplitude;
    
    // Medium frequency waves
    pattern += sin(dist * frequency * 40.0 * (1.0 + midIntensity) + angle * 2.0 - timeScale * 1.3) * amplitude * 0.7;
    
    // High frequency detail - affected by treble
    if (complexity > 0.2) {
        pattern += sin(dist * frequency * 80.0 * (1.0 + trebleIntensity) + angle * 4.0 - timeScale * 1.7) * amplitude * 0.5 * complexity;
    }
    
    // Very high frequency detail for more complexity
    if (complexity > 0.5) {
        pattern += sin(dist * frequency * 120.0 * (1.0 + trebleIntensity * 0.7) + angle * 6.0 - timeScale * 2.0) * amplitude * 0.3 * complexity;
    }
    
    return pattern;
}

// Main fragment shader function
void main() {
    // Calculate UV coordinates
    vec2 uv = gl_FragCoord.xy / vec2(iWidth, iHeight);
    
    // Skip effect if intensity is zero
    if (intensity <= 0.0) {
        gl_FragColor = texture(iTexture, uv);
        return;
    }
    
    // Generate base cymatics pattern
    float pattern = generateCymaticsPattern(uv, iTime);
    
    // Scale pattern by intensity
    pattern *= intensity;
    
    // Get base background color (default to dark blue if not specified)
    vec3 bgColor = hslToRgb(
        bgHue > 0.0 ? bgHue : 0.6,  // Default to blue
        bgSaturation > 0.0 ? bgSaturation : 0.8, 
        bgLightness > 0.0 ? bgLightness : 0.2
    );
    
    // Audio-reactive color modulation
    float audioColorEffect = mix(0.3, bassLevel * 0.6 + midLevel * 0.8 + trebleLevel * 0.4, audioSensitivity);
    
    // Calculate dynamic color based on pattern and audio
    vec3 patternColor = vec3(
        0.5 + 0.5 * sin(pattern * 3.0 + iTime * 0.2),
        0.5 + 0.5 * sin(pattern * 3.0 + iTime * 0.2 + PI/3.0),
        0.5 + 0.5 * sin(pattern * 3.0 + iTime * 0.2 + 2.0*PI/3.0)
    );
    
    // Brighten the pattern
    float brightness = 0.5 + 0.5 * pattern;
    
    // Mix background with pattern color based on pattern value and color intensity
    vec3 finalColor = mix(
        bgColor,
        patternColor * brightness,
        colorIntensity * (0.5 + 0.5 * pattern) * (1.0 + audioColorEffect)
    );
    
    // Check alpha of original texture to preserve transparency
    float alpha = texture(iTexture, uv).a;
    
    gl_FragColor = vec4(finalColor, alpha);
} 