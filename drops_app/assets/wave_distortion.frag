#version 300 es

precision highp float;

uniform float uTime;
uniform float uResolutionX;
uniform float uResolutionY;
uniform sampler2D uTexture;
uniform float uIntensity;
uniform float uSpeed;

out vec4 fragColor;

void main() {
  vec2 uv = gl_FragCoord.xy / vec2(uResolutionX, uResolutionY);
  
  // Get texture dimensions
  vec2 texSize = vec2(textureSize(uTexture, 0));
  float imageAspect = texSize.x / texSize.y;
  float screenAspect = uResolutionX / uResolutionY;
  
  // Calculate scaling to ensure both dimensions are fully covered
  vec2 scale = vec2(1.0);
  
  if (screenAspect > imageAspect) {
    // Screen is wider than image
    scale = vec2(screenAspect / imageAspect, 1.0) * 1.1;
  } else {
    // Screen is taller than image
    scale = vec2(1.0, imageAspect / screenAspect) * 1.1;
  }
  
  // Center the image with the new scaling
  vec2 centered = (uv - 0.5) / scale + 0.5;
  
  // Apply wave distortion
  float timeValue = uTime * uSpeed;
  float distortionAmount = uIntensity * 0.05;
  
  // Create wave pattern using multiple sine/cosine waves at different frequencies
  float wave1 = sin(centered.y * 10.0 + timeValue * 2.0) * 
                sin(centered.x * 8.0 + timeValue * 1.5);
                
  float wave2 = cos(centered.x * 12.0 - timeValue * 1.8) * 
                sin(centered.y * 6.0 + timeValue * 1.2);
                
  // More complex wave pattern that travels across the image
  float wave3 = sin(centered.x * 5.0 + centered.y * 6.0 + timeValue * 2.2) * 
                cos(centered.y * 4.0 - centered.x * 3.0 - timeValue * 1.9);
  
  // Combine waves with different weights
  float waveCombined = wave1 * 0.5 + wave2 * 0.3 + wave3 * 0.2;
  
  // Apply distortion - higher frequency near edges, less in the middle
  float distortionMultiplier = 0.3 + 0.7 * (
    pow(abs(centered.x - 0.5) * 2.0, 2.0) + 
    pow(abs(centered.y - 0.5) * 2.0, 2.0)
  );
  
  vec2 distortedUV = centered + vec2(
    waveCombined * distortionAmount * distortionMultiplier,
    waveCombined * distortionAmount * distortionMultiplier
  );
  
  // Ensure UV coordinates stay within bounds
  distortedUV = clamp(distortedUV, 0.0, 1.0);
  
  // Sample the texture with our distorted coordinates
  vec4 color = texture(uTexture, distortedUV);
  
  // Add subtle color shift based on wave intensity at higher intensity levels
  if (uIntensity > 0.7) {
    float colorShift = waveCombined * 0.1 * (uIntensity - 0.7) / 0.3;
    color.r += colorShift;
    color.g -= colorShift * 0.5;
    color.b += colorShift * 0.2;
  }
  
  // Handle images with transparency
  if (color.a < 1.0) {
    color = vec4(mix(vec3(0.0), color.rgb, color.a), 1.0);
  }
  
  fragColor = color;
} 