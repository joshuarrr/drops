# Shader Demo V2 Animation Behavior

**Affected Shaders**:

- Color Effect Shader
- Blur Effect Shader
- Noise Effect Shader
- Chromatic Effect Shader
- Rain Effect Shader
- Ripple Effect Shader

## Desired Animation Behavior

All lockable sliders now capture a **user-defined range**. By default the slider presents a single handle (max) with the minimum pinned at 0. When animation is toggled on—or when users lower the min—the dual-handle range becomes visible. Animations read exclusively from this min/max envelope.

### Animation Modes

1. **Pulse Mode**:
   - Creates a smooth oscillation between the user-defined **min** and **max** values on the range slider
   - Should follow a sine wave pattern
   - Speed controlled by the animation speed slider (affects only transition speed)
   - Animation should always start from the current value marker (no jumping)

2. **Randomized Mode**:
   - For unlocked parameters: Smoothly animates between random values constrained to the user-defined min/max window
   - Should continuously generate new random values with smooth transitions (no abrupt jumps)
   - Speed controlled by the animation speed slider (affects only transition speed)
   - Animation should always start from the current value marker (no jumping)

### Parameter Locking System

1. **Locked Parameters**:
   - When a parameter is locked:
     - Parameter stays fixed at the user’s max handle value (no animation)
     - Range slider collapses to a single static handle
     - This applies to both Pulse and Randomized modes

2. **Unlocked Parameters**:
   - When a parameter is unlocked:
     - In Pulse mode: Parameter oscillates between the user-defined min and max handles
     - In Randomized mode: Parameter animates between random values within the user-defined min/max window

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

1. **Ensure proper animation behavior**:
   - Make animations respect the user-defined slider values
   - Ensure animation speed, mode, and easing settings work correctly

2. **Parameter locking**:
   - Make locked parameters stay at their slider values
   - Make unlocked parameters animate according to the selected mode

3. **Apply fixes consistently across all shader effects**:
   - Ensure all shader types follow the same animation principles
   - Animation behavior should be consistent whether applied to text or image content when both "apply to text" and "apply to image" options are toggled
   - Multiple animated effects should operate independently
   Note: There may be subtle intensity adjustments when effects are applied to text vs. images to maintain text readability, but the animation behavior principles should remain consistent.

## Additional Requirements

1. **Range Slider & UI Feedback**:
   - Range sliders expose two handles (min/max) only when animation is enabled or the user adjusts the min handle; default state shows a single max handle with min anchored at 0
   - During animation the handles remain fixed; a single amber marker animates to reflect the live value being rendered
   - When animation is disabled the amber marker is hidden and the single handle resumes representing the stored max

2. **Preset Handling**:
   - When loading a preset with animations enabled, animations should automatically start
   - Presets must preserve animation settings (mode, speed, easing, lock states) **and** the stored min/max range for every parameter
