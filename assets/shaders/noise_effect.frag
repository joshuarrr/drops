#version 460 core

precision highp float;

// Input from Flutter
uniform sampler2D uTexture;
uniform float uTime;
uniform float uResolution; // aspect ratio
uniform float uNoiseScale; // Control for the noise scale
uniform float uNoiseSpeed; // Control for the animation speed
uniform float uColorIntensity; // Control for the color intensity
uniform float uWaveAmount; // Control for the wave distortion amount
uniform float uIsAnimated; // Flag indicating if animation is enabled (1.0) or disabled (0.0)

// Define output
out vec4 fragColor;

// Simplex noise function from Book of Shaders
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0; }
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }

float snoise(vec2 v) {
    const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                        0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                        -0.577350269189626,  // -1.0 + 2.0 * C.x
                        0.024390243902439); // 1.0 / 41.0
    
    // First corner
    vec2 i  = floor(v + dot(v, C.yy));
    vec2 x0 = v -   i + dot(i, C.xx);
    
    // Other corners
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    
    // Permutations
    i = mod289(i); // Avoid truncation effects in permutation
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
        + i.x + vec3(0.0, i1.x, 1.0 ));
        
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
    m = m*m;
    m = m*m;
    
    // Gradients: 41 points uniformly over a line, mapped onto a diamond.
    // The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    
    // Normalise gradients implicitly by scaling m
    // Approximation of: m *= inversesqrt( a0*a0 + h*h );
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    
    // Compute final noise value at P
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

// Rotation function
vec2 rotate(vec2 v, float a) {
    float s = sin(a);
    float c = cos(a);
    mat2 m = mat2(c, -s, s, c);
    return m * v;
}

void main() {
    vec2 uv = gl_FragCoord.xy / vec2(textureSize(uTexture, 0));
    
    // Apply aspect ratio correction
    vec2 st = uv;
    st.x *= uResolution;
    
    // Calculate noise
    float timeOffset = uTime * uNoiseSpeed;
    
    // Create noise coordinates based on animation state
    vec2 noiseCoords;
    if (uIsAnimated > 0.5) {
        // Animated mode - apply rotation and time offset
        // Use noise speed of at least 0.01 when animation is on but speed is 0
        float effectiveSpeed = max(uNoiseSpeed, 0.01);
        noiseCoords = rotate(st, uTime * 0.1) * uNoiseScale;
    } else {
        // Static mode - no time influence
        noiseCoords = st * uNoiseScale;
    }
    
    // Create noise-based distortion
    float noise1 = snoise(noiseCoords) * 0.5 + 0.5;
    float noise2 = snoise(noiseCoords * 2.0 + (uIsAnimated > 0.5 ? vec2(timeOffset) : vec2(0.0))) * 0.5 + 0.5;
    
    // Use noise to create wave-like distortion
    vec2 distortion;
    if (uIsAnimated > 0.5) {
        // Animated distortion based on time
        distortion = vec2(
            sin(noise1 * 6.28 + timeOffset) * uWaveAmount,
            cos(noise2 * 6.28 + timeOffset) * uWaveAmount
        );
    } else {
        // Static distortion
        distortion = vec2(
            sin(noise1 * 6.28) * uWaveAmount,
            cos(noise2 * 6.28) * uWaveAmount
        );
    }
    
    // Apply the distortion to the texture coordinates
    vec2 distortedUV = uv + distortion;
    
    // Sample the texture with distorted coordinates
    vec4 texColor = texture(uTexture, distortedUV);
    
    // Create gradient colors based on the noise
    vec3 color1 = vec3(0.949, 0.561, 0.792); // Pink
    vec3 color2 = vec3(0.463, 0.169, 0.690); // Purple
    vec3 noiseColor = mix(color1, color2, noise2);
    
    // Mix the texture with the noise color
    vec3 finalColor = mix(texColor.rgb, noiseColor, uColorIntensity);
    
    fragColor = vec4(finalColor, texColor.a);
} 