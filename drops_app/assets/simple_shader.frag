#version 300 es

precision highp float;

uniform float uTime;
uniform vec2 uResolution;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 uv = gl_FragCoord.xy / uResolution;
  
  // Create a simple effect
  vec2 distortedUV = uv + vec2(sin(uv.y * 10.0 + uTime) * 0.01, 0.0);
  
  vec4 color = texture(uTexture, distortedUV);
  
  fragColor = color;
} 