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

// Output to Flutter
out vec4 fragColor;

void main() {
  // Get normalized screen coordinates
  vec2 uv = gl_FragCoord.xy / vec2(uResolutionX, uResolutionY);
  
  // Get texture dimensions and calculate aspect ratios
  vec2 texSize = vec2(textureSize(uTexture, 0));
  float imageAspect = texSize.x / texSize.y;
  float screenAspect = uResolutionX / uResolutionY;
  
  // Calculate scaling to ensure both dimensions are fully covered
  vec2 scale = vec2(1.0);
  
  if (screenAspect > imageAspect) {
    // Screen is wider than image
    scale = vec2(screenAspect / imageAspect, 1.0);
  } else {
    // Screen is taller than image
    scale = vec2(1.0, imageAspect / screenAspect);
  }
  
  // Center the image with the new scaling
  vec2 centered = (uv - 0.5) / scale + 0.5;
  
  // Calculate parameters for chromatic aberration
  float amount = uAmount * 0.01; // Scale down for subtle effect
  
  // Apply animation if active
  if (uTime > 0.0) {
    float animFactor = (sin(uTime * 0.8) + 1.0) / 2.0;
    amount *= animFactor;
  }
  
  // Calculate direction vector based on angle
  float angleRad = radians(uAngle);
  vec2 direction = vec2(cos(angleRad), sin(angleRad));
  
  // Scale the chromatic offset based on distance from center (more at edges)
  float distFromCenter = length(centered - 0.5) * 2.0;
  float edgeFactor = smoothstep(0.0, 1.0, distFromCenter);
  
  // Calculate channel offsets with spread factor
  float spreadFactor = uSpread * 0.5;
  vec2 redOffset = -direction * amount * spreadFactor * (1.0 + edgeFactor);
  vec2 blueOffset = direction * amount * spreadFactor * (1.0 + edgeFactor);
  
  // Sample each color channel
  vec4 baseColor = texture(uTexture, centered);
  float r = texture(uTexture, clamp(centered + redOffset, 0.0, 1.0)).r;
  float g = baseColor.g; // Keep green channel centered for stability
  float b = texture(uTexture, clamp(centered + blueOffset, 0.0, 1.0)).b;
  
  // Create aberration color and blend based on intensity
  vec3 aberrationColor = vec3(r, g, b);
  vec3 finalColor = mix(baseColor.rgb, aberrationColor, uIntensity);
  
  // Preserve original alpha
  fragColor = vec4(finalColor, baseColor.a);
} 