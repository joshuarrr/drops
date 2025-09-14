# Shader Demo V2 Animation System Issues & Requirements

## Overview

This document outlines the current animation system issues in Shader Demo V2 and the requirements for implementing proper animation behavior with a 60-second maximum duration.

## Current System Analysis

### Speed Slider Range

- **Current Range**: 30s to 500ms (not 0.0-1.0)
- **UI Display**: Shows "30.0s" to "500ms" 
- **Actual Behavior**: Animation controller always runs 5-second cycles regardless of slider position

### Animation Controller

- **Fixed Duration**: Always 5 seconds (`Duration(seconds: 5)`)
- **Speed Application**: Speed slider value is used as a multiplier in animation calculations
- **Disconnect**: UI shows durations that don't match actual animation behavior

## Issue 1: Animation Speed Slider Bug

### Problem 1

When dragging the animation speed slider all the way to the left (minimum value), the UI displays "30s" but the animation actually stops completely instead of running at the slowest speed.

### Root Cause 1

**Location**: `lib/shader_demo_v2/utils/animation_utils.dart` lines 139 and 43

The animation calculations use speed as a direct multiplier:

```dart
// Pulse Mode (line 139)
final double pulseTime = baseTime * opts.speed * 2.0;

// Randomized Mode (line 43)  
final double scaledTime = (baseTime * opts.speed * 2.0);
```

When `opts.speed = 0.0` (minimum slider position):

- `pulseTime = baseTime * 0.0 * 2.0 = 0.0`
- `scaledTime = baseTime * 0.0 * 2.0 = 0.0`

This results in:

- **Pulse mode**: `math.sin(0.0 * math.pi).abs() = 0.0` → No oscillation
- **Randomized mode**: All sine wave calculations become `math.sin(0.0 * ...) = 0.0` → No variation

**The animation effectively stops because the time multiplier becomes zero.**

### Impact 1

Affects all animated shader effects in V2 (blur, color, noise, rain, chromatic, ripple).

### Solution 1

Use a non-zero minimum multiplier:

```dart
// Instead of: baseTime * opts.speed * 2.0
// Use: baseTime * (0.1 + opts.speed * 1.9) * 2.0
```

This ensures:

- Minimum speed (0.0) → multiplier = 0.1 (slowest but still animated)
- Maximum speed (1.0) → multiplier = 2.0 (fastest)

## Issue 2: Misleading UI Display

### Problem 2

**Location**: `lib/shader_demo_v2/widgets/animation_controls.dart` lines 120-130

The `_formatDuration()` method shows fake durations:

```dart
String _formatDuration(double speed) {
  // Map speed (0-1) to duration (30000ms to 500ms)
  final durationMs = 30000 - (speed * 29500);
  // ...
}
```

- UI shows "30s" but actual animation cycle is always 5 seconds
- The displayed duration is purely cosmetic and doesn't reflect actual animation behavior
- Users expect the displayed duration to match actual animation speed

### Solution 2

Update the duration mapping to reflect the new 60s maximum:

```dart
String _formatDuration(double speed) {
  // Map speed (0-1) to duration (60000ms to 500ms)
  final durationMs = 60000 - (speed * 59500);
  
  if (durationMs >= 1000) {
    final seconds = (durationMs / 1000).toStringAsFixed(1);
    return '${seconds}s';
  } else {
    return '${durationMs.round()}ms';
  }
}
```

## Issue 3: Fixed Animation Controller Duration

### Problem 3

**Location**: `lib/shader_demo_v2/views/shader_demo_screen.dart` lines 48-49

The animation controller uses a fixed 5-second cycle:

```dart
_animationController = AnimationController(
  duration: const Duration(seconds: 5), // Fixed 5 second cycle like V3
  vsync: this,
);
```

This creates a disconnect between what the UI shows and how animation actually works.

### Solution 3

Implement true duration control with 60s maximum:

```dart
Duration _calculateAnimationDuration(double speed) {
  // Map speed (0-1) to actual duration (60s to 0.5s)
  final durationMs = 60000 - (speed * 59500);
  return Duration(milliseconds: durationMs.round());
}

void _updateAnimationSpeed(double speed) {
  final newDuration = _calculateAnimationDuration(speed);
  
  if (_animationController.isAnimating) {
    _animationController.stop();
    _animationController.duration = newDuration;
    _animationController.reset();
    _animationController.repeat(reverse: true);
  } else {
    _animationController.duration = newDuration;
  }
}
```

## New Animation Behavior Requirements

### Pulse Mode with 60s Maximum Duration

With the new 60s maximum duration, Pulse mode behavior should be:

1. **Full Cycle Duration**: 60s (when speed slider is at minimum)
2. **Half Cycle**: 30s to go from slider value to zero
3. **Return Cycle**: 30s to go from zero back to slider value
4. **Speed Control**: Speed slider controls the actual duration (60s to 0.5s)

### Animation Flow

```text
Slider Value → 0 (30s) → Slider Value (30s) → repeat
```

### Randomized Mode with 60s Maximum Duration

1. **Full Cycle Duration**: 60s (when speed slider is at minimum)
2. **Random Value Generation**: Continuously generates new random values across parameter range
3. **Smooth Transitions**: No abrupt jumps between random values
4. **Speed Control**: Speed slider controls the actual duration (60s to 0.5s)

## Implementation Requirements

### 1. Update Animation Utilities

**File**: `lib/shader_demo_v2/utils/animation_utils.dart`

- Update duration constants to support 60s maximum
- Fix speed multiplier calculation to prevent zero-speed bug
- Ensure proper pulse and randomized behavior with new duration range

### 2. Update Animation Controller

**File**: `lib/shader_demo_v2/views/shader_demo_screen.dart`

- Implement dynamic duration control
- Add speed change handling with smooth transitions
- Ensure proper animation restart when duration changes

### 3. Update UI Display

**File**: `lib/shader_demo_v2/widgets/animation_controls.dart`

- Update `_formatDuration()` to show accurate durations (60s to 0.5s)
- Ensure UI reflects actual animation behavior

### 4. Apply to All Effect Panels

**Files**: All shader effect controllers

- Extend the working blur effect pattern to all other panels
- Ensure consistent animation behavior across all effects
- Apply UI feedback (position markers) to all panels

## Testing Requirements

### Pulse Mode Testing

1. **Minimum Speed (60s)**: Verify full cycle takes 60 seconds
2. **Half Cycle (30s)**: Verify slider-to-zero transition takes 30 seconds
3. **Maximum Speed (0.5s)**: Verify full cycle takes 0.5 seconds
4. **Speed Changes**: Verify smooth transitions when changing speed mid-animation

### Randomized Mode Testing

1. **Minimum Speed (60s)**: Verify random value changes occur over 60-second cycles
2. **Maximum Speed (0.5s)**: Verify rapid random value changes
3. **Parameter Locking**: Verify locked parameters stay at slider values
4. **Unlocked Parameters**: Verify smooth random animation across parameter ranges

### UI Testing

1. **Duration Display**: Verify UI shows accurate durations
2. **Position Markers**: Verify amber markers show original user-set positions
3. **Slider Movement**: Verify sliders reflect current animated values
4. **Lock/Unlock**: Verify lock states work correctly with new duration system

## Code References

- **Speed Display**: `lib/shader_demo_v2/widgets/animation_controls.dart:120-130`
- **Speed Usage**: `lib/shader_demo_v2/utils/animation_utils.dart:43,139`
- **Animation Controller**: `lib/shader_demo_v2/views/shader_demo_screen.dart:48-51`
- **Working Implementation**: `lib/shader_demo_v2/controllers/shaders/blur_effect_shader.dart:164-167,176-184`
- **Animation State Manager**: `lib/shader_demo_v2/controllers/animation_state_manager.dart`
- **UI Components**: `lib/shader_demo_v2/widgets/labeled_slider.dart`, `lib/shader_demo_v2/widgets/lockable_slider.dart`

## Priority Order

1. **Update duration constants** (enable 60s maximum)
2. **Implement dynamic duration control** (true speed control - removes need for multipliers)
3. **Update UI display** (honest duration display)
4. **Apply to all effect panels** (consistent behavior)
5. **Extend UI feedback** (position markers everywhere)
6. **Comprehensive testing** (verify all requirements)

## Implementation Strategy

Since we're implementing true duration control, we can **remove the multiplier approach entirely**. The speed slider will directly control the animation controller duration, eliminating the zero-speed bug and the need for complex multiplier calculations.
