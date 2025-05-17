# Shader Animation Controls Documentation

This document explains how the shader animation controls work in the Drops application.

## Architecture Overview

The shader animation system consists of several key components:

1. **Models** - Define the animation parameters and settings
2. **Controllers** - Manage animation state and apply animations to shaders
3. **UI Widgets** - Allow user control of animation parameters
4. **Shader Implementation** - Execute the actual animations on the GPU

## Animation Models

### AnimationOptions

The `AnimationOptions` class is the core model that defines how animations behave. It contains:

- `speed` (0.0-1.0): Controls animation speed (0.0 = slowest, 1.0 = fastest)
- `mode`: Defines the animation behavior pattern
  - `AnimationMode.pulse`: Smooth cycling pattern
  - `AnimationMode.randomixed`: Randomized transitions between values
- `easing`: Controls the animation timing function
  - `AnimationEasing.linear`: Constant rate of change
  - `AnimationEasing.easeIn`: Starts slow, accelerates
  - `AnimationEasing.easeOut`: Starts fast, decelerates
  - `AnimationEasing.easeInOut`: Slow start, accelerates in middle, decelerates at end

## Effect Settings

Animations can be applied to multiple shader effects, each with their own settings:

### ColorSettings

- Controls color transformations and overlays
- Contains animation options for both HSL adjustments and color overlays
- `colorAnimated`: Toggles HSL animation
- `overlayAnimated`: Toggles overlay animation

### BlurSettings

- Controls blur/shatter effects
- `blurAnimated`: Toggles blur animation
- Animation affects blur amount based on configured pattern

### NoiseSettings

- Controls noise and distortion effects
- `noiseAnimated`: Toggles noise animation
- Animation affects both noise patterns and wave distortion

## Animation Controllers

Animation controllers handle:

1. **Time Management**: Converts normalized time values (0.0-1.0) to animation patterns
2. **Mode Processing**: Implements pulse or randomized behavior based on mode settings
3. **Easing Application**: Applies timing curves based on easing settings
4. **Value Computation**: Calculates animated values for shader uniforms

Key helper functions:

- `_computeAnimatedValue()`: Maps base time to animated values based on options
- `_applyEasing()`: Applies selected easing curve to time values
- `_smoothRandom()`: Generates smoothly varying random values for randomized mode

## Time Scaling

Animation speed values (0.0-1.0) are mapped to actual durations:
- Slowest (0.0) = 30000ms cycle
- Fastest (1.0) = 300ms cycle

## UI Components

The animation controls UI is implemented in the `AnimationControls` widget, which provides:

1. **Speed Slider**: Adjusts animation speed
2. **Mode Selection**: Toggle between pulse and randomixed modes
3. **Easing Selection**: Choose different easing curves

## Shader Implementation

When effects are animated:

1. The `AnimatedSampler` widget updates shader uniforms on each frame
2. Animation values are computed based on current time and animation options
3. The computed values are passed to shader uniforms
4. Special handling is applied for text content to ensure readability

## Performance Considerations

- Animations dynamically adapt for text content with reduced intensity
- `preserveTransparency` flag adjusts animations to maintain transparency
- Text shaders use optimized parameters for better performance

## Known Issues and Improvement Areas

The current implementation has several areas that could be improved:

1. **Code Duplication**: The `_computeAnimatedValue()`, `_applyEasing()`, and `_smoothRandom()` functions are duplicated across shader effect classes. These should be refactored into a shared utility class.

2. **Performance**: 
   - For text content, blur radius is reduced by 40% to improve frame rate, but this is an ad-hoc optimization
   - Text overlay applies a 60% downscaling before shader effects and scales back up after, which could cause quality issues

3. **Inconsistent Special Cases**:
   - `BlurEffectShader` has a bug where it sets `effectiveRadius` twice for text content - once with a 40% reduction and then overrides it with the original value
   - Different shader types handle `preserveTransparency` and `isTextContent` cases differently

4. **Error Handling**:
   - Shader errors are caught and logged, but there's no recovery mechanism besides falling back to the original image
   - Error messages aren't user-friendly

5. **Animation Consistency**:
   - The animation constants (`_minDurationMs` and `_maxDurationMs`) are duplicated in multiple places with comments to "keep in sync with the demo"
   - Each shader has its own implementation of animation helpers with subtle differences

6. **Memory Management**:
   - The current implementation doesn't dispose of shader resources properly
   - The caching mechanism in `ShaderProgramLoader` doesn't handle resource constraints

7. **Debug Logging**:
   - Debug logs are controlled by different flags across components
   - Performance impact of logging isn't considered in production builds 

# Code duplication next steps

## Refactoring Plan: Animation Utilities

After analyzing the code, I found that the animation helper functions (`_computeAnimatedValue()`, `_applyEasing()`, and `_smoothRandom()`) are duplicated across all three shader effect classes (`ColorEffectShader`, `BlurEffectShader`, and `NoiseEffectShader`). Here's a detailed plan to refactor this code:

### 1. Create a New Utility Class

Create a new file `drops_app/lib/shader_demo/utils/animation_utils.dart`:

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/animation_options.dart';

/// Utility class for shader animation calculations
class ShaderAnimationUtils {
  // Animation duration bounds - centralized for consistency
  static const int minDurationMs = 30000; // slowest
  static const int maxDurationMs = 300; // fastest

  // Simple hash function for repeatable pseudo-random numbers
  static double hash(double x) {
    return (math.sin(x * 12.9898) * 43758.5453).abs() % 1;
  }

  // Smoothly varying random value in [0,1) for a given time
  static double smoothRandom(double t, {int segments = 8}) {
    final double scaled = t * segments;
    final double idx0 = scaled.floorToDouble();
    final double idx1 = idx0 + 1.0;
    final double frac = scaled - idx0;

    final double r0 = hash(idx0);
    final double r1 = hash(idx1);

    // Smooth interpolation using easeInOut for softer transitions
    final double eased = Curves.easeInOut.transform(frac);
    return ui.lerpDouble(r0, r1, eased)!;
  }

  // Apply easing curve to a normalized time value
  static double applyEasing(AnimationEasing easing, double t) {
    switch (easing) {
      case AnimationEasing.easeIn:
        return Curves.easeIn.transform(t);
      case AnimationEasing.easeOut:
        return Curves.easeOut.transform(t);
      case AnimationEasing.easeInOut:
        return Curves.easeInOut.transform(t);
      case AnimationEasing.linear:
      default:
        return t;
    }
  }

  // Compute the animated value (0-1) for the given options using the shared base time
  static double computeAnimatedValue(AnimationOptions opts, double baseTime) {
    // Map the normalized speed to a duration
    final double durationMs = ui.lerpDouble(
      minDurationMs.toDouble(),
      maxDurationMs.toDouble(),
      opts.speed,
    )!;

    // Translate duration back into a speed factor relative to the slowest
    final double speedFactor = minDurationMs / durationMs;

    // Scale time – keep it in [0,1)
    final double scaledTime = (baseTime * speedFactor) % 1.0;

    // Apply animation mode
    final double modeValue = opts.mode == AnimationMode.pulse
        ? scaledTime
        : smoothRandom(scaledTime);

    // Apply easing and return
    return applyEasing(opts.easing, modeValue);
  }
}
```

### 2. Update Each Shader Widget Class

Modify `drops_app/lib/shader_demo/controllers/custom_shader_widgets.dart` to:

1. Import the new utility class
2. Remove the duplicated helper functions
3. Replace calls to the helper functions with calls to the utility class methods

For example, in `ColorEffectShader`:

```dart
import '../utils/animation_utils.dart';

// Remove the existing helper functions:
// - _hash
// - _smoothRandom
// - _applyEasing 
// - _computeAnimatedValue

// Replace calls like:
final double hslAnimValue = _computeAnimatedValue(colorOpts, animationValue);

// With:
final double hslAnimValue = ShaderAnimationUtils.computeAnimatedValue(colorOpts, animationValue);
```

And make similar changes to `BlurEffectShader` and `NoiseEffectShader`.

### 3. Update the Main Demo Implementation 

Update `drops_app/lib/shader_demo/shader_demo_impl.dart` to use the shared utilities instead of its local implementations. This ensures that the same animation calculations are used throughout the app.

### 4. Fix the Regression Bug in BlurEffectShader

While refactoring, fix the bug in the BlurEffectShader where `effectiveRadius` is set twice:

```dart
if (isTextContent) {
  effectiveRadius = effectiveRadius * 0.6; // 40% reduction
  if (enableShaderDebugLogs) {
    print(
      "SHATTER_SHADER: Reducing radius for text content from ${settings.blurSettings.blurRadius} to $effectiveRadius",
    );
  }
} else {
  effectiveRadius = settings.blurSettings.blurRadius; // This overwrites the reduction!
}
```

Replace with:

```dart
if (isTextContent) {
  effectiveRadius = effectiveRadius * 0.6; // 40% reduction
  if (enableShaderDebugLogs) {
    print(
      "SHATTER_SHADER: Reducing radius for text content from ${settings.blurSettings.blurRadius} to $effectiveRadius",
    );
  }
}
```


After this refactoring, consider:

1. Centralizing other duplicated code, like error handling and logging in shader effects
2. Creating a base class for shader effects to reduce boilerplate
3. Standardizing the handling of `preserveTransparency` and `isTextContent` flags across all shader types
