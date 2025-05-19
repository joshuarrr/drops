#version 460 core
precision highp float;

// Texture samplers
uniform sampler2D iImage; // Input image

// Screen dimensions and time
uniform float iWidth;     // Screen width
uniform float iHeight;    // Screen height
uniform float iTime;      // Animation time (0-1)

// Ripple effect parameters
uniform float iIntensity; // Ripple intensity
uniform float iSize;      // Ripple size
uniform float iSpeed;     // Ripple speed
uniform float iOpacity;   // Effect opacity
uniform float iColorFactor; // Color influence

// Output
out vec4 fragColor;

// Random function for noise
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void main() {
    // Get normalized coordinates
    vec2 uv = vec2(gl_FragCoord.x / iWidth, gl_FragCoord.y / iHeight);
    
    // Ensure aspect ratio is maintained
    float aspect = iWidth / iHeight;
    vec2 center = vec2(0.5, 0.5);
    
    // Adjust UV for aspect ratio
    vec2 adjustedUV = uv;
    adjustedUV.x *= aspect;
    center.x *= aspect;
    
    // Calculate distance from center
    float dist = distance(adjustedUV, center);
    
    // Create multiple ripple waves for more interesting effect
    float wave1 = sin(dist * iSize * 30.0 - iTime * iSpeed * 3.0) * iIntensity * 0.03;
    float wave2 = sin(dist * iSize * 20.0 - iTime * iSpeed * 2.0 + 1.3) * iIntensity * 0.02;
    float wave3 = sin(dist * iSize * 10.0 - iTime * iSpeed * 1.0 + 2.9) * iIntensity * 0.01;
    
    // Combine waves
    float ripple = wave1 + wave2 + wave3;
    
    // Add some random noise to break up the perfectness of the ripples
    float noise = random(uv + iTime * 0.1) * 0.002 * iIntensity;
    ripple += noise;
    
    // Calculate distortion based on distance from center
    float edgeFactor = smoothstep(0.0, 0.5, 1.0 - dist * 1.5); // Less effect at edges
    ripple *= edgeFactor;
    
    // Apply ripple displacement to texture coordinates
    vec2 rippleUV = uv + vec2(ripple, ripple);
    
    // Sample the original texture
    vec4 color = texture(iImage, rippleUV);
    
    // Apply subtle color tint based on ripple displacement
    vec4 rippleColor = mix(
        color, 
        vec4(
            color.r + ripple * 2.0, 
            color.g + ripple, 
            color.b + ripple * 3.0, 
            color.a
        ), 
        iColorFactor
    );
    
    // Blend between original and ripple effect based on opacity
    fragColor = mix(color, rippleColor, iOpacity);
} 