# Shader System Cheatsheet

## Overview

The Drops app uses a custom shader system built on top of Flutter's fragment shaders. This system allows for applying multiple visual effects including:

- Color adjustments
- Chromatic aberration
- Noise effects
- Rain effects 
- Ripple effects
- Blur effects

## Shader Architecture

### Structure

1. **Effect Controller**: Central orchestrator (`effect_controller.dart`) that manages which effects are applied and in what order
2. **Shader Widgets**: Individual effect implementations (e.g., `ripple_effect_shader.dart`)
3. **GLSL Shaders**: Actual shader code (e.g., `ripple_effect.frag`)
4. **Settings Models**: Data models that contain parameters for each effect

### Application Flow

1. `EffectController.applyEffects()` - Entry point that takes a widget and applies all enabled effects
2. `_buildEffectsWidget()` - Wraps the original widget and applies each shader in sequence
3. Individual `_apply[Effect]Effect()` methods - Apply specific effects if enabled
4. Shader widget classes - Handle the actual rendering using Flutter's ShaderBuilder

## Key Lessons for Writing Shaders

### Coordinate System Handling

**Important**: When implementing shaders, use Flutter's coordinate system correctly:

```glsl
#include <flutter/runtime_effect.glsl>

void main() {
    // Get coordinates using Flutter's coordinate system
    vec2 fragCoord = FlutterFragCoord();
    
    // Normalize coordinates correctly
    vec2 uv = fragCoord/vec2(iWidth, iHeight);
    
    // ...rest of shader
}
```

### Image Sizing Issues

**Problem**: The ripple shader was resizing the background image, while other shaders maintained proper size.

**Root causes**:
1. Incorrect aspect ratio handling in the fragment shader
2. Unnecessary LayoutBuilder/SizedBox wrapping in the shader widget
3. Differences in coordinate calculations between shaders

**Solution**:
1. Use `FlutterFragCoord()` to get correct screen coordinates
2. Remove aspect ratio adjustments from UV coordinates
3. Match the widget structure of working shaders (like ChromaticEffectShader)
4. Clamp texture sampling coordinates to prevent out-of-bounds issues

### Shader Widget Implementation Best Practices

1. **Keep it simple**: Don't nest LayoutBuilder and SizedBox unnecessarily
2. **Consistent parameter passing**: Pass canvas size directly to the shader
3. **Uniform naming**: Keep uniform variable names consistent across shaders
4. **Error handling**: Always include fallback drawing code on shader exceptions

## Parameter Passing Guide

When setting shader parameters, maintain consistent ordering:

```dart
// Set the texture sampler first
shader.setImageSampler(0, image);

// Size parameters next
shader.setFloat(0, size.width);
shader.setFloat(1, size.height);

// Animation/time parameters
shader.setFloat(2, timeValue);

// Effect-specific parameters last
shader.setFloat(3, intensity);
// etc...
```

## Debugging Tips

1. Enable verbose logging with the appropriate debug flags
2. Log canvas and image sizes to track potential resizing issues
3. Use consistent debug approach across all shaders

## Testing New Shaders

When creating a new shader effect:

1. Start by copying the structure of existing working shaders (e.g., ColorEffectShader)
2. Ensure coordinate systems match Flutter's expectations
3. Test with various parent widget sizes to ensure proper scaling
4. Implement fallback drawing for robustness

## Applying Multiple Effects

Effects are currently applied in this order in `_buildEffectsWidget()`:

1. Color effects (first)
2. Noise effects 
3. Rain effects
4. Ripple effects
5. Chromatic effects
6. Blur effects (last)

Consider effect ordering when designing new shaders, as some effects may not work well if applied in a different order.
