#version 460 core

precision highp float;

// Input from Flutter
uniform sampler2D uTexture;    // Main texture to be distorted
uniform sampler2D uNoiseTexture; // Noise texture for random values (need to add this)
uniform float uTime;
uniform float uResolution; // aspect ratio
uniform float uRainIntensity; // Controls number of drops (0-1)
uniform float uDropSize; // Controls size of droplets (0-1, scaled internally)
uniform float uFallSpeed; // Controls speed of falling drops (0-1)
uniform float uRefraction; // Controls visual distortion from drops (0-1)
uniform float uTrailIntensity; // Controls length/opacity of trails behind drops (0-1)
uniform float uIsAnimated; // Flag indicating if animation is enabled (1.0) or disabled (0.0)

// Define output
out vec4 fragColor;

// Random and noise functions
float random(vec2 p) {
    vec3 p3 = fract(vec3(p.xyx) * 0.1031);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract((p3.x + p3.y) * p3.z);
}

float noise(vec2 x) {
    vec2 i = floor(x);
    vec2 f = fract(x);
    
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void main() {
    // Get normalized screen coordinates
    vec2 uv = gl_FragCoord.xy / vec2(textureSize(uTexture, 0));
    
    // Original UV for final sampling
    vec2 sampleUV = uv;
    
    // Apply aspect ratio for consistent drop shapes
    float aspect = uResolution;
    
    // Calculate effective time for animation
    float effectiveTime;
    if (uIsAnimated > 0.5) {
        // When animated, use the time provided
        effectiveTime = uTime * (0.2 + uFallSpeed * 0.8); // Speed range 0.2x-1.0x
    } else {
        // Static mode - fixed pattern
        effectiveTime = 0.0;
    }

    // Simulate the noise texture using our internal noise function
    // In a real implementation, we would use the actual uNoiseTexture
    vec2 n = vec2(noise(uv * 10.0), noise(uv * 10.0 + vec2(123.45, 678.90)));
    
    // Grid-based approach for multiple raindrop layers
    // Number of layers scales with intensity (1-4 range)
    int numLayers = int(1.0 + uRainIntensity * 3.0);
    
    for (float r = float(numLayers); r > 0.0; r--) {
        // Define the grid for this layer - larger numbers = smaller grid
        float gridScale = 0.015 * (0.5 + uDropSize * 1.0);
        vec2 x = vec2(textureSize(uTexture, 0)) * r * gridScale;
        
        // Create periodic pattern with some randomness
        vec2 p = 6.28318 * uv * x + (n - 0.5) * 2.0;
        vec2 s = sin(p);
        
        // Generate stable random values for each grid cell
        float cellX = floor(uv.x * x.x);
        float cellY = floor(uv.y * x.y);
        vec2 cellCoord = vec2(cellX, cellY) / x;
        
        // Use procedural random values for different drop properties
        float dropRandomR = random(cellCoord * 12.34);
        float dropRandomG = random(cellCoord * 45.67);
        float dropRandomB = random(cellCoord * 89.01);
        
        // Calculate the drop shape and intensity
        float dropIntensity = (s.x + s.y) * max(0.0, 1.0 - fract(effectiveTime * (dropRandomB + 0.1) + dropRandomG) * 2.0);
        
        // Only draw drops that pass these tests (controls frequency)
        float dropThreshold = (5.0 - r) * 0.08 * (0.2 + uRainIntensity * 0.8);
        if (dropRandomR < dropThreshold && dropIntensity > 0.5) {
            // Calculate drop normal for 3D effect
            vec3 normal = normalize(-vec3(cos(p), mix(0.2, 2.0, dropIntensity - 0.5)));
            
            // Apply refraction based on normal
            float refractionStrength = 0.05 + uRefraction * 0.45;
            
            // Apply the distortion to the UV based on the normal direction
            sampleUV = uv - normal.xy * refractionStrength;
            
            // Add trails if enabled
            if (uTrailIntensity > 0.0 && uIsAnimated > 0.5) {
                float trailLength = uTrailIntensity * 0.3 * (1.0 + uFallSpeed);
                int trailCount = int(1.0 + uTrailIntensity * 2.0);
                
                for (int t = 1; t <= trailCount; t++) {
                    float trailOffset = float(t) * 0.05;
                    vec2 trailCellCoord = vec2(cellCoord.x, fract(cellCoord.y + trailOffset));
                    
                    // Get random values for the trail drop
                    float trailRandomR = random(trailCellCoord * 12.34);
                    float trailRandomG = random(trailCellCoord * 45.67);
                    
                    // Make the trail diminish in strength
                    float trailFactor = 1.0 - float(t) / float(trailCount + 1);
                    if (trailRandomR < dropThreshold * trailFactor) {
                        vec2 trailP = 6.28318 * uv * x + (n - 0.5) * 2.0;
                        trailP.y += trailOffset * 10.0;
                        
                        vec2 trailS = sin(trailP);
                        float trailIntensity = (trailS.x + trailS.y) * 0.5 * trailFactor;
                        
                        if (trailIntensity > 0.2) {
                            vec3 trailNormal = normalize(-vec3(cos(trailP), mix(0.2, 1.0, trailIntensity)));
                            sampleUV = sampleUV - trailNormal.xy * refractionStrength * trailFactor * 0.5;
                        }
                    }
                }
            }
        }
    }
    
    // Sample the texture with our distorted coordinates
    vec4 color = texture(uTexture, sampleUV);
    
    // Output final color
    fragColor = color;
} 