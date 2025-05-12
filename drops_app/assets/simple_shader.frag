#version 300 es

precision highp float;

uniform float uTime;
uniform vec2 uResolution;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 uv = gl_FragCoord.xy / uResolution;
  
  // Calculate aspect ratio to ensure image fills screen
  float imageAspect = float(textureSize(uTexture, 0).x) / float(textureSize(uTexture, 0).y);
  float screenAspect = uResolution.x / uResolution.y;
  
  // Adjust UVs to fill screen while maintaining aspect ratio
  vec2 adjustedUV = uv;
  if (screenAspect > imageAspect) {
    // Screen is wider than image
    float scale = screenAspect / imageAspect;
    adjustedUV.x = (uv.x - 0.5) * scale + 0.5;
  } else {
    // Screen is taller than image
    float scale = imageAspect / screenAspect;
    adjustedUV.y = (uv.y - 0.5) * scale + 0.5;
  }
  
  // Apply distortion effect
  vec2 distortedUV = adjustedUV + vec2(
    sin(adjustedUV.y * 10.0 + uTime) * 0.01, 
    cos(adjustedUV.x * 10.0 + uTime) * 0.01
  );
  
  vec4 color = texture(uTexture, distortedUV);
  
  fragColor = color;
} 