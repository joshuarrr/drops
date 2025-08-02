# Shader Demo V2 Animation Implementation Context

## Current Implementation Analysis

### Animation Controller

- Located in `lib/shader_demo_v2/views/shader_demo_screen.dart` (specifically V2 version, not V3)
- Uses Flutter's `AnimationController` with a fixed 5-second cycle
- Animation detection logic in `_hasActiveAnimations()` checks if effects are both enabled AND animated
- Currently using V3-style direct animation approach

### Animation Utilities

- Located in `lib/shader_demo_v2/utils/animation_utils.dart`
- Contains proper utilities that aren't being used:
  - `computeAnimatedValue()` - For general animation calculations
  - `computePulseValue()` - For pulse-specific calculations
  - `computeRandomizedParameterValue()` - For randomized animations with parameter ranges
- Supports both Pulse and Randomized modes with proper easing

### Parameter Locking System

- Managed by `AnimationStateManager` singleton in `lib/shader_demo_v2/controllers/animation_state_manager.dart`
- Provides methods for checking lock states and updating animated values
- Currently bypassed by V3-style direct animation approach

### Shader-Specific Implementations

#### Color Effect Shader

- Located in `lib/shader_demo_v2/controllers/shaders/color_effect_shader.dart`
- Currently uses hardcoded values: `hue = animationValue; saturation = 1.0; lightness = 0.5`
- Bypasses animation options and parameter locking

#### Blur Effect Shader

- Located in `lib/shader_demo_v2/controllers/shaders/blur_effect_shader.dart`
- Uses direct animation with amplified values: `amount = baseAmount * animFactor * 2.0`
- Bypasses animation options and parameter locking

#### Noise Effect Shader

- Located in `lib/shader_demo_v2/controllers/shaders/noise_effect_shader.dart`
- Has proper implementation with both pulse and randomized modes
- Correctly uses `AnimationStateManager` for parameter locking
- Currently bypassed by V3-style direct animation approach

#### Chromatic Effect Shader

- Located in `lib/shader_demo_v2/controllers/shaders/chromatic_effect_shader.dart`
- Has proper implementation with parameter locking
- Currently bypassed by V3-style direct animation approach

#### Rain Effect Shader

- Located in `lib/shader_demo_v2/controllers/shaders/rain_effect_shader.dart`
- Has proper implementation with parameter animation
- Currently bypassed by V3-style direct animation approach

#### Ripple Effect Shader

- Located in `lib/shader_demo_v2/controllers/shaders/ripple_effect_shader.dart`
- Has proper implementation with parameter animation
- Currently bypassed by V3-style direct animation approach

## Implementation Plan

### 1. Restore Animation Utility Usage - Incremental Approach

- Start with a single shader (Blur Effect) as a proof of concept
- Replace direct V3-style animation with calls to proper utility methods
- Ensure animation speed, mode, and easing settings are respected
- Key files to modify:
  - `lib/shader_demo_v2/controllers/shaders/blur_effect_shader.dart` (first)  
  - `lib/shader_demo_v2/views/shader_demo_screen.dart` (animation controller)
  
Once Blur Effect is working correctly, apply the same pattern to other shaders one by one.

### 2. Restore Parameter Locking

- Focus first on Blur Effect shader as proof of concept
- Ensure `AnimationStateManager` is properly consulted for parameter lock states
- Implement correct behavior for locked vs. unlocked parameters
- Key files to modify:
  - `lib/shader_demo_v2/controllers/shaders/blur_effect_shader.dart` (first)

After validating with Blur Effect, apply to other shaders incrementally.

### 3. Ensure UI Feedback

- Make sliders reflect current animated values
- Ensure slider positions match actual parameter values during animation
- Key files to modify:
  - `lib/shader_demo_v2/widgets/lockable_slider.dart`
  - `lib/shader_demo_v2/controllers/animation_state_manager.dart` integration

### 4. Fix Preset Handling

- Ensure presets preserve animation settings
- Make loading presets with animations automatically start them
- Key files to modify:
  - `lib/shader_demo_v2/models/presets_manager.dart`
  - Preset loading logic in shader controllers

## Key Challenges

1. **Balancing Animation Visibility with Control**
   - Need to ensure animations are visible while respecting slider values
   - May require adjustments to animation utility methods

2. **Consistent Implementation Across Shaders**
   - Each shader has unique parameters but should follow consistent animation principles
   - Need to ensure consistent behavior while preserving shader-specific adjustments

3. **Smooth Transitions**
   - Ensure all animations start from current slider values
   - Prevent jumps or abrupt changes when toggling animations
