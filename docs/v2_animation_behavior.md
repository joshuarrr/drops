# Shader Demo V2 Animation Behavior

## Current Issues

The current animation implementation in Shader Demo V2 is using the v3 simple animation. It currently has the following issues:

1. **Animation is working but not respecting slider controls**:
   - Animations are visible but don't respect user-defined slider values
   - Animation speed, mode, and easing settings from UI controls have no effect
   - Parameter locking system is currently bypassed

2. **Affected Shaders**:
   - Color Effect Shader
   - Blur Effect Shader
   - Noise Effect Shader
   - Chromatic Effect Shader
   - Rain Effect Shader
   - Ripple Effect Shader

## Desired Animation Behavior

### Animation Modes

1. **Pulse Mode**:
   - Creates a smooth oscillation between the user-defined slider value and zero, then back to the slider value
   - Should follow a sine wave pattern
   - Speed controlled by the animation speed slider (affects only transition speed)
   - Animation should always start from the current slider value (no jumping)

2. **Randomized Mode**:
   - For unlocked parameters: Smoothly animates from the user-defined slider value to random values across the parameter's full range (min to max)
   - Should continuously generate new random values to animate between with smooth transitions (no abrupt jumps)
   - Speed controlled by the animation speed slider (affects only transition speed)
   - Animation should always start from the current slider value (no jumping)

### Parameter Locking System

1. **Locked Parameters**:
   - When a parameter is locked:
     - Parameter stays fixed at the slider value (no animation)
     - This applies to both Pulse and Randomized modes

2. **Unlocked Parameters**:
   - When a parameter is unlocked:
     - In Pulse mode: Parameter oscillates between the slider value and zero, then back to the slider value
     - In Randomized mode: Parameter animates between the slider value and random values across the parameter's full range

### Animation Controls

1. **Speed Slider**:
   - Controls how fast animations run (0.0=slowest, 1.0=fastest)
   - Should affect both Pulse and Randomized modes

2. **Animation Mode Selection**:
   - Switches between Pulse and Randomized patterns
   - Should apply to all animated parameters

3. **Easing Curves**:
   - Applies the selected easing curve (only linear and easeInOut options available)
   - Should affect both Pulse and Randomized modes
   - Controls how animations accelerate/decelerate during transitions

## Implementation Priorities

1. **Restore proper animation behavior**:
   - Make animations respect the user-defined slider values
   - Ensure animation speed, mode, and easing settings work correctly

2. **Fix parameter locking**:
   - Make locked parameters stay at their slider values
   - Make unlocked parameters animate according to the selected mode

3. **Apply fixes consistently across all shader effects**:
   - Ensure all shader types follow the same animation principles
   - Animation behavior should be consistent whether applied to text or image content when both "apply to text" and "apply to image" options are toggled
   - Multiple animated effects should operate independently
   Note: There may be subtle intensity adjustments when effects are applied to text vs. images to maintain text readability, but the animation behavior principles should remain consistent.

## Additional Requirements

1. **UI Feedback**:
   - Sliders should move to reflect the current animated value
   - Slider positions should always match the actual parameter values during animation

2. **Preset Handling**:
   - When loading a preset with animations enabled, animations should automatically start
   - Preset should preserve all animation settings (mode, speed, easing, lock states)
