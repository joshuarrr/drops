#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

// Inputs
uniform sampler2D uTexture;
uniform float uTime;
uniform vec2 uResolution;
uniform float uType;       // 0=Bayer, 1=Random, 2=Atkinson (simulated)
uniform float uPixelSize;  // pixel block size in px
uniform float uColorSteps; // quantization steps per channel
uniform float uIsTextContent;

out vec4 fragColor;

// 4x4 Bayer matrix normalized to [0,1)
const mat4 bayer4x4 = mat4(
  0.0,  8.0,  2.0, 10.0,
 12.0,  4.0, 14.0,  6.0,
  3.0, 11.0,  1.0,  9.0,
 15.0,  7.0, 13.0,  5.0
);

float bayerThreshold(ivec2 p) {
  int x = p.x & 3;
  int y = p.y & 3;
  float v = bayer4x4[y][x];
  return (v + 0.5) / 16.0; // normalize
}

// Quantize a channel to N steps
float quantize(float v, float steps) {
  return floor(v * steps) / steps;
}

// Simple ordered dithering using Bayer matrix
vec3 orderedDither(vec2 uv, ivec2 ip, vec3 rgb, float steps) {
  float t = bayerThreshold(ip);
  vec3 q = vec3(
    quantize(rgb.r + (t - 0.5) / steps, steps),
    quantize(rgb.g + (t - 0.5) / steps, steps),
    quantize(rgb.b + (t - 0.5) / steps, steps)
  );
  return clamp(q, 0.0, 1.0);
}

// Random dithering
float hash(vec2 p) {
  // low-cost hash
  return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

vec3 randomDither(vec2 uv, ivec2 ip, vec3 rgb, float steps) {
  float n = hash(uv * uResolution.xy);
  vec3 q = vec3(
    quantize(rgb.r + (n - 0.5) / steps, steps),
    quantize(rgb.g + (n - 0.5) / steps, steps),
    quantize(rgb.b + (n - 0.5) / steps, steps)
  );
  return clamp(q, 0.0, 1.0);
}

// Lightweight Atkinson-like effect: sample local mean and push toward nearest step
vec3 atkinsonApprox(vec2 uv, ivec2 ip, vec3 rgb, float steps) {
  vec2 texel = 1.0 / uResolution;
  vec3 sum = rgb;
  sum += texture(uTexture, uv + texel * vec2(1.0, 0.0)).rgb;
  sum += texture(uTexture, uv + texel * vec2(2.0, 0.0)).rgb;
  sum += texture(uTexture, uv + texel * vec2(-1.0, 0.0)).rgb;
  sum += texture(uTexture, uv + texel * vec2(0.0, 1.0)).rgb;
  sum += texture(uTexture, uv + texel * vec2(0.0, 2.0)).rgb;
  vec3 avg = sum / 7.0;
  vec3 q = vec3(
    quantize(avg.r, steps),
    quantize(avg.g, steps),
    quantize(avg.b, steps)
  );
  // Mix toward quantized neighborhood to emulate diffusion
  return clamp(mix(rgb, q, 0.85), 0.0, 1.0);
}

void main() {
  vec2 fragCoord = FlutterFragCoord();
  vec2 uv = fragCoord / uResolution.xy;

  vec4 color = texture(uTexture, uv);
  if (color.a < 0.01) {
    fragColor = color;
    return;
  }
  if (uIsTextContent > 0.5) {
    fragColor = color;
    return;
  }

  // Pixelate sampling grid for stable dithering blocks
  float px = max(1.0, floor(uPixelSize + 0.5));
  vec2 block = floor(fragCoord / px) * px + px * 0.5;
  vec2 uvBlock = block / uResolution.xy;
  vec3 rgb = texture(uTexture, uvBlock).rgb;

  float steps = max(2.0, floor(uColorSteps + 0.5));
  ivec2 ip = ivec2(block);

  vec3 outRGB;
  if (uType < 0.5) {
    outRGB = orderedDither(uvBlock, ip, rgb, steps);
  } else if (uType < 1.5) {
    outRGB = randomDither(uvBlock, ip, rgb, steps);
  } else {
    outRGB = atkinsonApprox(uvBlock, ip, rgb, steps);
  }

  fragColor = vec4(outRGB, color.a);
}


