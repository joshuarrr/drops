#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

// Input from Flutter
uniform sampler2D uTexture;        // The input image texture
uniform float uTime;               // Animation time (seconds)
uniform vec2 uResolution;          // Screen resolution (width, height)
uniform float uOpacity;            // Effect opacity (0.0 to 1.0)
uniform float uNoiseIntensity;     // Noise threshold (0.0 to 1.0)
uniform float uFieldLines;         // Field lines per second (100.0 to 400.0)
uniform float uHorizontalWaveStrength; // Horizontal wave strength (0.0 to 0.5)
uniform float uHorizontalWaveScreenSize; // Horizontal wave screen size (10.0 to 200.0)
uniform float uHorizontalWaveVerticalSize; // Horizontal wave vertical size (10.0 to 300.0)
uniform float uDottedNoiseStrength; // Dotted noise strength (0.0 to 1.0)
uniform float uHorizontalDistortionStrength; // Horizontal distortion strength (0.0 to 0.02)
uniform float uIsTextContent;      // Flag for text content (1.0 = text)

// Define output
out vec4 fragColor;

// Random hash function
vec4 hash42(vec2 p) {
    vec4 p4 = fract(vec4(p.xyxy) * vec4(443.8975, 397.2973, 491.1871, 470.7827));
    p4 += dot(p4.wzxy, p4 + 19.19);
    return fract(vec4(p4.x * p4.y, p4.x * p4.z, p4.y * p4.w, p4.x * p4.w));
}

float hash(float n) {
    return fract(sin(n) * 43758.5453123);
}

// 3D noise function
float noise3d(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f * f * (3.0 - 2.0 * f);
    float n = p.x + p.y * 57.0 + 113.0 * p.z;
    float res = mix(mix(mix(hash(n + 0.0), hash(n + 1.0), f.x),
                        mix(hash(n + 57.0), hash(n + 58.0), f.x), f.y),
                    mix(mix(hash(n + 113.0), hash(n + 114.0), f.x),
                        mix(hash(n + 170.0), hash(n + 171.0), f.x), f.y), f.z);
    return res;
}

// Tape noise function
float tapeNoise(vec2 p, float time) {
    float y = p.y;
    float s = time * 2.0;
    
    float v = (noise3d(vec3(y * 0.01 + s, 1.0, 1.0)) + 0.0)
           * (noise3d(vec3(y * 0.011 + 1000.0 + s, 1.0, 1.0)) + 0.0) 
           * (noise3d(vec3(y * 0.51 + 421.0 + s, 1.0, 1.0)) + 0.0);
    
    v *= hash42(vec2(p.x + time * 0.01, p.y)).x + 0.3;
    
    v = pow(v + 0.3, 1.0);
    if (v < (1.0 - uNoiseIntensity)) v = 0.0; // Higher intensity keeps more noise
    
    return v;
}

// Random function for distortion
float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233) * 3.141)) * 43758.5453);
}

void main() {
    // Get fragment coordinate using Flutter's helper function
    vec2 fragCoord = FlutterFragCoord();
    
    // Normalized pixel coordinates (from 0 to 1)
    vec2 uv = fragCoord / uResolution.xy;
    vec2 uv_org = vec2(uv);
    
    // Skip processing for text content
    if (uIsTextContent > 0.5) {
        fragColor = texture(uTexture, uv);
        return;
    }
    float baseTime = uTime;

    // Horizontal wave distortion driven by smooth sine wave
    vec2 waveUV = uv_org;
    if (uHorizontalWaveStrength > 0.001) {
        float frequencyT = clamp(uHorizontalWaveScreenSize / 200.0, 0.0, 1.0);
        float frequency = mix(2.0, 40.0, frequencyT);
        float travelSpeed = mix(0.5, 3.0, frequencyT);
        float directionNoise = noise3d(vec3(floor(baseTime * 0.25), 13.0, 7.0));
        float direction = 1.0 - 2.0 * step(0.5, directionNoise);

        float envelope = 1.0;
        if (uHorizontalWaveVerticalSize > 0.0) {
            float halfHeight = uHorizontalWaveVerticalSize / uResolution.y;
            halfHeight = max(halfHeight, 0.001);
            float verticalScroll = mix(0.1, 1.2, frequencyT) * direction;
            float bandCenter = fract(0.5 + baseTime * verticalScroll);
            float relativeY = waveUV.y - bandCenter;
            relativeY -= floor(relativeY + 0.5);
            float dist = relativeY / halfHeight;
            envelope = exp(-dist * dist * 0.5);
        }

        float phaseNoise = noise3d(vec3(waveUV.y * 18.0, baseTime * 0.35, 2.0));
        float amplitudeNoise = noise3d(vec3(waveUV.y * 24.0 + 31.0, baseTime * 0.2, 5.0));
        float burstNoise = noise3d(vec3(floor(baseTime * 1.8), waveUV.y * 12.0, 8.0));

        float wavePhase = waveUV.y * frequency - baseTime * travelSpeed * direction;
        wavePhase += (phaseNoise - 0.5) * 6.28318;

        float amplitudeScale = mix(0.4, 1.3, amplitudeNoise);
        float burstGate = smoothstep(0.15, 0.75, burstNoise);

        float waveOffset = sin(wavePhase) * uHorizontalWaveStrength * envelope * amplitudeScale * burstGate;
        waveUV.x += waveOffset;
    }

    // Subtle horizontal distortion for authenticity
    if (uHorizontalDistortionStrength > 0.0001) {
        float distortionFreq = mix(2.0, 8.0, clamp(uHorizontalWaveScreenSize / 200.0, 0.0, 1.0));
        float distortion = sin((waveUV.y - baseTime * 1.2 * direction) * distortionFreq * 6.28318);
        waveUV.x += distortion * uHorizontalDistortionStrength;
    }

    waveUV = clamp(waveUV, vec2(0.0), vec2(1.0));

    // Sample the texture with distortion
    vec4 color = texture(uTexture, waveUV);

    // Apply dotted noise effect for speckled grain
    if (uDottedNoiseStrength > 0.001) {
        vec2 dotCoord = floor((uv_org * uResolution.xy) / 2.0);
        float verticalShift = baseTime * 24.0;
        float dotSeed = hash42(vec2(dotCoord.x, dotCoord.y + verticalShift)).x;
        float dotMask = step(1.0 - uDottedNoiseStrength, dotSeed);
        color.rgb = mix(color.rgb, vec3(dotSeed), dotMask * uDottedNoiseStrength);
    }

    // Apply field line quantization (VHS scanlines) and tape noise when enabled
    if (uFieldLines > 1.0 && uNoiseIntensity > 0.0) {
        float linesN = uFieldLines;
        float one_y = uResolution.y / linesN;
        vec2 quantizedUV = floor(uv_org * uResolution.xy / one_y) * one_y;
        float noise = tapeNoise(quantizedUV, baseTime);
        color.rgb = mix(color.rgb, vec3(noise), noise * uNoiseIntensity);
    } else if (uNoiseIntensity > 0.0) {
        float noise = tapeNoise(uv_org * uResolution.xy, baseTime);
        color.rgb = mix(color.rgb, vec3(noise), noise * 0.1 * uNoiseIntensity);
    }
    
    // Apply opacity
    color.a *= uOpacity;
    
    fragColor = color;
}
