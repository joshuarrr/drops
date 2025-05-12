#version 300 es

precision highp float;

uniform float uTime;
uniform vec2 uResolution;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 uv = gl_FragCoord.xy / uResolution;
  
  // Reduce overscale factor to improve performance
  const float overscaleFactor = 1.2; // Reduced from 2.0 to 1.2 for better performance
  
  // Get texture dimensions
  vec2 texSize = vec2(textureSize(uTexture, 0));
  float imageAspect = texSize.x / texSize.y;
  float screenAspect = uResolution.x / uResolution.y;
  
  // Calculate scaling to ensure both dimensions are fully covered
  vec2 scale = vec2(1.0);
  
  if (screenAspect > imageAspect) {
    // Screen is wider than image - scale based on width but ensure height fills too
    scale = vec2(screenAspect / imageAspect, 1.0) * overscaleFactor;
  } else {
    // Screen is taller than image - scale based on height but ensure width fills too
    scale = vec2(1.0, imageAspect / screenAspect) * overscaleFactor;
  }
  
  // Center the image with the new scaling
  vec2 centered = (uv - 0.5) / scale + 0.5;
  
  // Simplify distortion effect to improve performance
  vec2 distortedUV = centered + vec2(
    sin(centered.y * 4.0 + uTime) * 0.001, // Reduced frequency and amplitude
    cos(centered.x * 4.0 + uTime) * 0.001
  );
  
  // Use normal clamp to prevent image "cropping"
  distortedUV = clamp(distortedUV, 0.0, 1.0);
  
  vec4 color = texture(uTexture, distortedUV);
  
  // Handle images with transparency
  if (color.a < 1.0) {
    color = vec4(mix(vec3(0.0), color.rgb, color.a), 1.0);
  }
  
  fragColor = color;
} 