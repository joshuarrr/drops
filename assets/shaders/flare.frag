#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

uniform sampler2D uTexture;
uniform float uTime;
uniform vec2 uResolution;
uniform float uDistortion;   // warp distortion strength
uniform float uSwirl;        // vortex distortion strength
uniform float uGrainMixer;   // mixer (shape) grain
uniform float uGrainOverlay; // rgb overlay grain
uniform float uOffsetX;
uniform float uOffsetY;
uniform float uScale;
uniform float uRotationDeg;
uniform float uIsText;
uniform float uOpacity;

// 4 colors
uniform float uC0R; uniform float uC0G; uniform float uC0B; uniform float uC0A;
uniform float uC1R; uniform float uC1G; uniform float uC1B; uniform float uC1A;
uniform float uC2R; uniform float uC2G; uniform float uC2B; uniform float uC2A;
uniform float uC3R; uniform float uC3G; uniform float uC3B; uniform float uC3A;

out vec4 fragColor;

// Utility noise ------------------------------------------------------------
float h21(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }

float valueNoise(vec2 st) {
  vec2 i = floor(st);
  vec2 f = fract(st);
  float a = h21(i);
  float b = h21(i + vec2(1.0, 0.0));
  float c = h21(i + vec2(0.0, 1.0));
  float d = h21(i + vec2(1.0, 1.0));
  vec2 u = f*f*(3.0-2.0*f);
  float x1 = mix(a, b, u.x);
  float x2 = mix(c, d, u.x);
  return mix(x1, x2, u.y);
}

float noise(vec2 n) { return valueNoise(n); }

mat2 rot2(float a) { return mat2(cos(a), -sin(a), sin(a), cos(a)); }

float hash(vec2 p){
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec3 mix4(vec3 a, vec3 b, vec3 c, vec3 d, vec2 uv){
  vec3 ab = mix(a, b, uv.x);
  vec3 cd = mix(c, d, uv.x);
  return mix(ab, cd, uv.y);
}

void main(){
  vec2 fragCoord = FlutterFragCoord();
  vec2 uv = fragCoord / uResolution.xy;

  vec4 base = texture(uTexture, uv);
  if (base.a < 0.01) { fragColor = base; return; }
  float textFactor = (uIsText > 0.5) ? 0.0 : 1.0;

  // Prepare local coordinates with transform
  vec2 p = uv;
  p -= 0.5;
  p = rot2(radians(uRotationDeg)) * p;
  p *= uScale;
  p += vec2(uOffsetX, uOffsetY);
  vec2 q = p + 0.5; // back to 0..1

  // Grain UV: inverse transform to respect origin
  vec2 grainUV = (rot2(-radians(uRotationDeg)) * (uv - 0.5)) * uScale * 0.7;
  grainUV -= vec2(uOffsetX, -uOffsetY);
  grainUV *= min(uResolution.x, uResolution.y);
  float grain = noise(grainUV);
  float mixerGrain = 0.4 * uGrainMixer * (grain - 0.5);

  // Time (first frame offset like Paper to avoid symmetry)
  float t = 0.5 * (uTime + 41.5);

  // Distortion toward center
  float radius = length(q - 0.5);
  float center = 1.0 - radius;
  vec2 shape_uv = q;
  for (float i = 1.0; i <= 2.0; i += 1.0) {
    shape_uv.x += uDistortion * center / i *
                  sin(t + i * 0.4 * smoothstep(0.0, 1.0, shape_uv.y)) *
                  cos(0.2 * t + i * 2.4 * smoothstep(0.0, 1.0, shape_uv.y));
    shape_uv.y += uDistortion * center / i *
                  cos(t + i * 2.0 * smoothstep(0.0, 1.0, shape_uv.x));
  }

  // Swirl based on radius
  vec2 uvRotated = shape_uv - 0.5;
  float angle = 3.0 * uSwirl * radius;
  uvRotated = rot2(-angle) * uvRotated + 0.5;

  // Multi-spot gradient (positions + weighted blend)
  vec3 c0 = vec3(uC0R, uC0G, uC0B);
  vec3 c1 = vec3(uC1R, uC1G, uC1B);
  vec3 c2 = vec3(uC2R, uC2G, uC2B);
  vec3 c3 = vec3(uC3R, uC3G, uC3B);
  vec4 cols[4];
  cols[0] = vec4(c0, 1.0);
  cols[1] = vec4(c1, 1.0);
  cols[2] = vec4(c2, 1.0);
  cols[3] = vec4(c3, 1.0);

  vec3 color = vec3(0.0);
  float opacityMesh = 0.0;
  float totalW = 0.0;

  for (int i=0; i<4; i++) {
    float a = float(i) * 0.37;
    float b = 0.6 + mod(float(i), 3.0) * 0.3;
    float c = 0.8 + mod(float(i+1), 4.0) * 0.25;
    vec2 pos = 0.5 + 0.5 * vec2(sin(t*b + a), cos(t*c + a*1.5));
    pos += mixerGrain;

    float dist = length(uvRotated - pos);
    dist = pow(dist, 3.5);
    float w = 1.0 / (dist + 1e-3);
    color += cols[i].rgb * cols[i].a * w;
    opacityMesh += cols[i].a * w;
    totalW += w;
  }

  color /= max(1e-3, totalW);
  opacityMesh /= max(1e-3, totalW);

  // Grain overlay (rgb) per Paper
  float rr = noise((rot2(1.0) * grainUV) + vec2(3.0));
  float gg = noise((rot2(2.0) * grainUV) + vec2(-1.0));
  float bb = noise(grainUV + vec2(5.0));
  vec3 grainColor = vec3(rr, gg, bb);
  color = mix(color, grainColor, 0.01 + 0.3 * uGrainOverlay);

  // Remove grain for a smooth Paper-like look (can be reintroduced later)

  // Composite with source image (soft-light style)
  vec3 m = clamp(color, 0.0, 1.0);
  vec3 col = mix(base.rgb, 1.0 - (1.0 - 2.0*m) * (1.0 - base.rgb), uOpacity * textFactor);
  fragColor = vec4(col, base.a);
}


