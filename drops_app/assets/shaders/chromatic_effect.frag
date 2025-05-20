#version 460 core

#include <flutter/runtime_effect.glsl>

// Input from Flutter
uniform vec2 iResolution;     // Resolution (width, height)
uniform float iTime;          // Time in seconds
uniform float iIntensity;     // Intensity of the effect
uniform float iAmount;        // Amount of aberration
uniform float iAngle;         // Direction of aberration in degrees
uniform float iSpread;        // Spread between color channels
uniform sampler2D iChannel0;  // Input texture

out vec4 fragColor;

#define INVERT_Y 0
#define PI 3.14159265359

// Adjusts the RGB aberration amount based on input parameters
vec2 getAberrationOffset(float channel, float angle, float amount, float spread) {
    // Convert angle from degrees to radians
    float radAngle = radians(angle);
    
    // Adjust spread per channel (R=-1, G=0, B=1)
    float channelOffset = (channel - 1.0) * spread;
    
    // Calculate offset direction based on angle
    vec2 direction = vec2(cos(radAngle), sin(radAngle));
    
    // Calculate offset magnitude based on amount parameter
    return direction * amount * channelOffset;
}

float correctLensDistortionR(float x)
{
  float a = -0.01637 + 0.01;
  float b = -0.03 + 0.01;
  float c = -0.06489 + 0.01;
  float d = 1.0 - (a + b + c);

  return (x*x*x*x * a + x*x*x * b + x*x * c + d * x);
}

float correctLensDistortionG(float x)
{
  float a = -0.01637;
  float b = -0.03;
  float c = -0.06489;
  float d = 1.0 - (a + b + c);

  return (x*x*x*x * a + x*x*x * b + x*x * c + d * x);
}

float correctLensDistortionB(float x)
{
  float a = -0.01637 - 0.01;
  float b = -0.03 - 0.01;
  float c = -0.06489 - 0.01;
  float d = 1.0 - (a + b + c);

  return (x*x*x*x * a + x*x*x * b + x*x * c + d * x);
}

void main()
{
    // Get the fragment coordinate
    vec2 fragCoord = FlutterFragCoord();
    
    // Normalized pixel coordinates (from 0 to 1 for both x,y regardless of aspect)
    vec2 uv = fragCoord/iResolution.xy;

#if INVERT_Y
    uv.y = 1.0 - uv.y;
#endif // INVERT_Y
    
    // Sample the original texture to get alpha
    vec4 originalColor = texture(iChannel0, uv);
    
    // If pixel is fully transparent, keep it transparent
    if (originalColor.a < 0.01) {
        fragColor = vec4(0.0, 0.0, 0.0, 0.0);
        return;
    }
    
    // get polar coordinates - maintain aspect ratio better
    vec2 cart = (uv - vec2(0.5)) * 2.0;  // 0->1 to -1->1
    // Preserve aspect ratio without squishing the image
    float aspectRatio = iResolution.x / iResolution.y;
    cart.x *= aspectRatio;
    
    float an = atan(cart.y, cart.x);
    float len = length(cart);
    
    // Apply lens distortion only to color separation, not to overall image dimensions
    float lenR = len + (correctLensDistortionR(len) - len) * iIntensity;
    float lenG = len + (correctLensDistortionG(len) - len) * iIntensity;
    float lenB = len + (correctLensDistortionB(len) - len) * iIntensity;

    // back to cartesian
    vec2 dir = normalize(vec2(cos(an), sin(an)));
                
    vec2 modUV_R = (dir * lenR / aspectRatio) * 0.5 + vec2(0.5);
    vec2 modUV_G = (dir * lenG / aspectRatio) * 0.5 + vec2(0.5);
    vec2 modUV_B = (dir * lenB / aspectRatio) * 0.5 + vec2(0.5);
    
    float animSpeed = 0.5;
    float blendFactor = sin(iTime * animSpeed) * 0.5 + 0.5;
    
    // Apply intensity parameter to control color separation strength without affecting overall dimensions
    blendFactor *= iIntensity;
    
    // Use a smaller base value for aberration offsets to prevent excessive distortion
    float aberrationScale = 0.03;
    
    // Incorporate angle and spread parameters into the effect
    vec2 rOffset = getAberrationOffset(0.0, iAngle, iAmount * aberrationScale, iSpread);
    vec2 gOffset = getAberrationOffset(1.0, iAngle, iAmount * aberrationScale, iSpread);
    vec2 bOffset = getAberrationOffset(2.0, iAngle, iAmount * aberrationScale, iSpread);
    
    // Apply directional aberration without excessive distortion
    vec2 fetchUV_R = mix(uv, uv + rOffset * iIntensity, blendFactor);
    vec2 fetchUV_G = mix(uv, uv + gOffset * iIntensity, blendFactor);
    vec2 fetchUV_B = mix(uv, uv + bOffset * iIntensity, blendFactor);
    
    // Ensure UVs stay within bounds to avoid artifacts
    fetchUV_R = clamp(fetchUV_R, vec2(0.0), vec2(1.0));
    fetchUV_G = clamp(fetchUV_G, vec2(0.0), vec2(1.0));
    fetchUV_B = clamp(fetchUV_B, vec2(0.0), vec2(1.0));
    
    // fetch texture data
    vec3 col = vec3( 
        texture(iChannel0, fetchUV_R).r,
        texture(iChannel0, fetchUV_G).g,
        texture(iChannel0, fetchUV_B).b
    );
    
    // Output to screen with original alpha
    fragColor = vec4(col, originalColor.a);
} 