#version 460 core

// Input from Flutter
uniform float uTime;
uniform float uResolutionX;
uniform float uResolutionY;
uniform sampler2D uTexture;
uniform float uAmount;
uniform float uSpread;
uniform float uIntensity;
uniform float uAngle;
uniform float uImageWidth;
uniform float uImageHeight;

// Output to Flutter
out vec4 fragColor;

void main() {
  // Get normalized coordinates in [0,1] range
  vec2 uv = gl_FragCoord.xy / vec2(uResolutionX, uResolutionY);
  
  // Calculate parameters for chromatic aberration
  float amount = uAmount * 0.05; // Scale factor for aberration
  
  // Apply animation if active
  if (uTime > 0.0) {
    float animFactor = (sin(uTime * 0.8) + 1.0) / 2.0;
    amount *= 0.5 + 0.5 * animFactor;
  }
  
  // Calculate angle in radians
  float angleRad = radians(uAngle);
  vec2 direction = vec2(cos(angleRad), sin(angleRad));
  
  // Calculate offsets that scale with the resolution to prevent image shrinking
  // Scale offset based on a percentage of screen size rather than absolute pixels
  vec2 redOffset = -direction * amount * uSpread;
  vec2 blueOffset = direction * amount * uSpread;
  
  // Sample from main texture
  vec4 baseColor = texture(uTexture, uv);
  
  // Sample the red and blue channels with their respective offsets
  // Clamp UV coordinates to prevent out-of-bounds sampling
  vec2 redUV = clamp(uv + redOffset, vec2(0.0), vec2(1.0));
  vec2 blueUV = clamp(uv + blueOffset, vec2(0.0), vec2(1.0));
  
  vec4 redSample = texture(uTexture, redUV);
  vec4 blueSample = texture(uTexture, blueUV);
  
  // Create the final color with chromatic aberration
  vec4 finalColor = vec4(
    redSample.r,       // Red channel from offset red sample
    baseColor.g,       // Green channel from base color (no offset)
    blueSample.b,      // Blue channel from offset blue sample
    baseColor.a        // Keep original alpha
  );
  
  // Calculate effective intensity with a better curve for user control
  float effectiveIntensity = pow(uIntensity, 0.8);
  
  // Blend between original color and aberrated color based on intensity
  fragColor = mix(baseColor, finalColor, effectiveIntensity);
} 