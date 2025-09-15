# How to Implement a New Shader in Flutter

This document outlines the process for adding a new shader effect to the application. Following these steps will ensure your shader integrates properly with the existing architecture.

## 1. Create the GLSL Shader File

Create a new `.frag` file in the `assets/shaders/` directory:

```glsl
#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

// Input from Flutter
uniform sampler2D uTexture;        // The input image texture
uniform float uTime;               // Animation time (seconds)
uniform vec2 uResolution;          // Screen resolution (width, height)
uniform float uIsTextContent;      // Flag for text content (1.0 = text)
// Add your custom uniforms here

// Define output
out vec4 fragColor;

void main() {
    // CRITICAL: Get the fragment coordinate using Flutter's helper function
    // This is essential for proper coordinate handling in Flutter
    vec2 fragCoord = FlutterFragCoord();
    
    // Normalized pixel coordinates (from 0 to 1)
    // This creates proper UV coordinates for texture sampling
    vec2 uv = fragCoord/uResolution.xy;
    
    // Sample the texture
    vec4 color = texture(uTexture, uv);
    
    // Skip processing for transparent pixels
    if (color.a < 0.01) {
        fragColor = color;
        return;
    }
    
    // Skip processing for text content if needed
    if (uIsTextContent > 0.5) {
        fragColor = color;
        return;
    }
    
    // Add your shader effect logic here
    // ...
    
    // Example: Simple color modification
    vec3 result = color.rgb;
    
    // Apply your effect
    // ...
    
    // Output the final color
    fragColor = vec4(result, color.a);
}
```

## 2. Create a Settings Model

Create a new settings class in `lib/shader_demo_v2/models/` to store your shader's parameters:

```dart
import 'package:flutter/material.dart';
import 'animation_options.dart';

class YourEffectSettings {
  bool _effectEnabled;
  double _opacity;
  // Add your effect parameters here
  bool _effectAnimated;
  double _animationSpeed;
  AnimationOptions _animOptions;

  static bool enableLogging = false;

  YourEffectSettings({
    bool effectEnabled = false,
    double opacity = 0.5,
    // Initialize your parameters with defaults
    bool effectAnimated = false,
    double animationSpeed = 1.0,
    AnimationOptions? animOptions,
  })  : _effectEnabled = effectEnabled,
        _opacity = opacity,
        _effectAnimated = effectAnimated,
        _animationSpeed = animationSpeed,
        _animOptions = animOptions ?? AnimationOptions();

  // Getters
  bool get effectEnabled => _effectEnabled;
  double get opacity => _opacity;
  bool get effectAnimated => _effectAnimated;
  double get animationSpeed => _animationSpeed;
  AnimationOptions get effectAnimOptions => _animOptions;
  // Add getters for your parameters

  // Setters
  set effectEnabled(bool value) => _effectEnabled = value;
  set opacity(double value) => _opacity = value;
  set effectAnimated(bool value) => _effectAnimated = value;
  set animationSpeed(double value) => _animationSpeed = value;
  // Add setters for your parameters

  // Convenience getter to check if effect should be applied
  bool get shouldApplyEffect => _effectEnabled && _opacity >= 0.01;

  // Create a copy with updated values
  YourEffectSettings copyWith({
    bool? effectEnabled,
    double? opacity,
    // Add your parameters here
    bool? effectAnimated,
    double? animationSpeed,
    AnimationOptions? animOptions,
  }) {
    return YourEffectSettings(
      effectEnabled: effectEnabled ?? _effectEnabled,
      opacity: opacity ?? _opacity,
      // Update your parameters
      effectAnimated: effectAnimated ?? _effectAnimated,
      animationSpeed: animationSpeed ?? _animationSpeed,
      animOptions: animOptions ?? _animOptions,
    );
  }

  // Reset to default values
  void reset() {
    _effectEnabled = false;
    _opacity = 0.5;
    // Reset your parameters
    _effectAnimated = false;
    _animationSpeed = 1.0;
    _animOptions = AnimationOptions();
  }

  // Convert to map for serialization
  Map<String, dynamic> toMap() {
    return {
      'effectEnabled': _effectEnabled,
      'opacity': _opacity,
      // Add your parameters
      'effectAnimated': _effectAnimated,
      'animationSpeed': _animationSpeed,
      'animOptions': _animOptions.toMap(),
    };
  }

  // Create from map for deserialization
  static YourEffectSettings fromMap(Map<String, dynamic> map) {
    return YourEffectSettings(
      effectEnabled: map['effectEnabled'] ?? false,
      opacity: map['opacity'] ?? 0.5,
      // Initialize your parameters
      effectAnimated: map['effectAnimated'] ?? false,
      animationSpeed: map['animationSpeed'] ?? 1.0,
      animOptions: map['animOptions'] != null
          ? AnimationOptions.fromMap(Map<String, dynamic>.from(map['animOptions']))
          : null,
    );
  }

  @override
  String toString() {
    return 'YourEffectSettings(enabled: $_effectEnabled, opacity: $_opacity, animated: $_effectAnimated)';
  }
}
```

## 3. Update the Main Settings Class

Add your settings to `lib/shader_demo_v2/models/effect_settings.dart`:

```dart
// Add import
import 'your_effect_settings.dart';

class ShaderSettings {
  // Add your settings field
  YourEffectSettings _yourEffectSettings;
  
  // Add getter
  YourEffectSettings get yourEffectSettings => _yourEffectSettings;
  
  // Add convenience getter and setter
  bool get yourEffectEnabled => _yourEffectSettings.effectEnabled;
  set yourEffectEnabled(bool value) { _yourEffectSettings.effectEnabled = value; }

  // Update constructor
  ShaderSettings._internal()
    : /* other initializers */,
      _yourEffectSettings = YourEffectSettings();
      
  // Update constructor parameters
  ShaderSettings({
    // Other parameters
    YourEffectSettings? yourEffectSettings,
  }) : /* other initializers */,
       _yourEffectSettings = yourEffectSettings ?? YourEffectSettings();
       
  // Update toMap()
  Map<String, dynamic> toMap() {
    return {
      // Other settings
      'yourEffectSettings': _yourEffectSettings.toMap(),
    };
  }
  
  // Update fromMap()
  static ShaderSettings fromMap(Map<String, dynamic> map) {
    return ShaderSettings(
      // Other settings
      yourEffectSettings: map['yourEffectSettings'] != null
          ? YourEffectSettings.fromMap(
              Map<String, dynamic>.from(map['yourEffectSettings']),
            )
          : null,
    );
  }
}
```

## 4. Create the Shader Widget

Create a new file in `lib/shader_demo_v2/controllers/shaders/your_effect_shader.dart`:

```dart
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

import '../../models/effect_settings.dart';
import 'debug_flags.dart';

/// Custom shader widget for your effect
class YourEffectShader extends StatelessWidget {
  final Widget child;
  final ShaderSettings settings;
  final double animationValue;
  final bool preserveTransparency;
  final bool isTextContent;
  final String _logTag = 'YourEffectShader';

  // Log throttling
  static DateTime _lastLogTime = DateTime.now().subtract(const Duration(seconds: 1));
  static const Duration _logThrottleInterval = Duration(milliseconds: 1000);
  static String _lastLogMessage = "";

  const YourEffectShader({
    super.key,
    required this.child,
    required this.settings,
    required this.animationValue,
    this.preserveTransparency = false,
    this.isTextContent = false,
  });

  // Custom log function
  void _log(String message) {
    if (!enableShaderDebugLogs) return;
    if (message == _lastLogMessage) return;
    
    final now = DateTime.now();
    if (now.difference(_lastLogTime) < _logThrottleInterval) return;
    
    _lastLogTime = now;
    _lastLogMessage = message;
    
    developer.log(message, name: _logTag);
    debugPrint('[$_logTag] $message');
  }

  @override
  Widget build(BuildContext context) {
    if (enableShaderDebugLogs) {
      _log("Building YourEffectShader with opacity=${settings.yourEffectSettings.opacity.toStringAsFixed(2)}");
    }

    // Skip if effect is disabled or opacity is too low
    if (!settings.yourEffectSettings.shouldApplyEffect) {
      return child;
    }

    // Use ShaderBuilder with AnimatedSampler
    return ShaderBuilder(
      assetKey: 'assets/shaders/your_effect.frag',
      (context, shader, child) {
        return AnimatedSampler(
          (image, size, canvas) {
            try {
              _renderShader(shader, image, size, canvas);
            } catch (e) {
              _log("ERROR in shader: $e");
              _fallbackRender(image, size, canvas);
            }
          },
          child: this.child,
        );
      },
      child: child,
    );
  }

  void _renderShader(
    ui.FragmentShader shader,
    ui.Image image,
    Size size,
    Canvas canvas,
  ) {
    // Set the texture sampler first
    shader.setImageSampler(0, image);

    // Set uniforms in the correct order matching the shader
    shader.setFloat(0, settings.yourEffectSettings.effectAnimated ? animationValue : 0.0); // uTime
    shader.setFloat(1, size.width); // uResolution.x
    shader.setFloat(2, size.height); // uResolution.y
    shader.setFloat(3, settings.yourEffectSettings.opacity); // uOpacity
    // Set your custom uniforms here
    // ...
    
    // Set text content flag last
    shader.setFloat(/* last index */, isTextContent ? 1.0 : 0.0); // uIsTextContent

    // Draw with shader
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  void _fallbackRender(ui.Image image, Size size, Canvas canvas) {
    // Fall back to drawing original image
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );
  }
}

// Helper function to apply your effect
Widget applyYourEffect({
  required Widget child,
  required ShaderSettings settings,
  required double animationValue,
  bool preserveTransparency = false,
  bool isTextContent = false,
}) {
  return YourEffectShader(
    settings: settings,
    animationValue: animationValue,
    child: child,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
  );
}
```

## 5. Add Shader to Index File

Update `lib/shader_demo_v2/controllers/shaders/index.dart`:

```dart
// Add your shader export
export 'your_effect_shader.dart' hide enableShaderDebugLogs;

// Add helper function export
export 'your_effect_shader.dart' show applyYourEffect;
```

## 6. Update the Effect Controller

Modify `lib/shader_demo_v2/controllers/effect_controller.dart`:

```dart
// Update the effect check
if (!settings.colorEnabled &&
    !settings.blurEnabled &&
    // ...
    !settings.yourEffectEnabled) {
  return child;
}

// Update the animation check
bool isAnimated =
    (settings.colorSettings.colorAnimated && settings.colorEnabled) ||
    // ...
    (settings.yourEffectSettings.effectAnimated && settings.yourEffectEnabled);

// Add animation value calculation
if (settings.yourEffectEnabled && settings.yourEffectSettings.effectAnimated) {
  animationValues['yourEffect'] = animationValue;
}

// Add your effect to the effect chain
if (settings.yourEffectEnabled) {
  result = _applyYourEffect(
    child: result,
    settings: settings,
    animationValue: animationValues['yourEffect'] ?? 0.0,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
  );
}

// Add helper method
static Widget _applyYourEffect({
  required Widget child,
  required ShaderSettings settings,
  required double animationValue,
  bool preserveTransparency = false,
  bool isTextContent = false,
}) {
  if (!settings.yourEffectSettings.shouldApplyEffect) {
    return child;
  }

  return applyYourEffect(
    settings: settings,
    animationValue: animationValue,
    child: child,
    preserveTransparency: preserveTransparency,
    isTextContent: isTextContent,
  );
}
```

## 7. Add to Shader Aspect Enum

Update `lib/shader_demo_v2/models/shader_effect.dart`:

```dart
enum ShaderAspect {
  background,
  color,
  blur,
  // ...
  yourEffect,
}

// Update extension methods
extension ShaderAspectExtension on ShaderAspect {
  String get label {
    switch (this) {
      // ...
      case ShaderAspect.yourEffect:
        return 'Your Effect';
    }
  }

  IconData get icon {
    switch (this) {
      // ...
      case ShaderAspect.yourEffect:
        return Icons.auto_fix_high; // Choose appropriate icon
    }
  }
}
```

## 8. Create Control Panel

Create a new file in `lib/shader_demo_v2/widgets/your_effect_panel.dart`:

```dart
import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/presets_manager.dart';
import '../services/preset_refresh_service.dart';
import 'lockable_slider.dart';
import 'animation_controls.dart';
import 'enhanced_panel_header.dart';

class YourEffectPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const YourEffectPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<YourEffectPanel> createState() => _YourEffectPanelState();
}

class _YourEffectPanelState extends State<YourEffectPanel> {
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    // Ensure effect is enabled when panel is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.settings.yourEffectEnabled) {
        final updatedSettings = widget.settings;
        updatedSettings.yourEffectEnabled = true;
        widget.onSettingsChanged(updatedSettings);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnhancedPanelHeader(
          aspect: ShaderAspect.yourEffect,
          onPresetSelected: _applyPreset,
          onReset: _resetEffect,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: true,
          applyToText: false,
          onApplyToImageChanged: (value) {
            // Handle if needed
          },
          onApplyToTextChanged: (value) {
            // Handle if needed
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              
              // Opacity slider
              LockableSlider(
                label: 'Effect Opacity',
                value: widget.settings.yourEffectSettings.opacity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: '${(widget.settings.yourEffectSettings.opacity * 100).round()}%',
                onChanged: (value) => _onOpacityChanged(value),
                activeColor: widget.sliderColor,
                parameterId: 'your_effect_opacity',
                animationEnabled: widget.settings.yourEffectSettings.effectAnimated,
                defaultValue: 0.5,
              ),
              
              const SizedBox(height: 16),
              
              // Add your parameter sliders here
              // ...
              
              const SizedBox(height: 16),
              
              // Animation controls
              AnimationControls(
                animationSpeed: widget.settings.yourEffectSettings.animationSpeed,
                onSpeedChanged: _onAnimationSpeedChanged,
                animationMode: AnimationMode.pulse,
                onModeChanged: (mode) {}, // If you support different modes
                animationEasing: AnimationEasing.linear,
                onEasingChanged: (easing) {}, 
                sliderColor: widget.sliderColor,
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  // Handle slider changes
  void _onOpacityChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.yourEffectSettings.opacity = value;
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation speed changes
  void _onAnimationSpeedChanged(double speed) {
    final updatedSettings = widget.settings;
    updatedSettings.yourEffectSettings.animationSpeed = speed;
    widget.onSettingsChanged(updatedSettings);
  }

  // Reset settings to defaults
  void _resetEffect() {
    final updatedSettings = widget.settings;
    updatedSettings.yourEffectSettings.reset();
    widget.onSettingsChanged(updatedSettings);
  }

  // Apply preset
  void _applyPreset(Map<String, dynamic> presetData) {
    final updatedSettings = widget.settings;
    
    // Apply preset values
    updatedSettings.yourEffectEnabled = presetData['effectEnabled'] ?? true;
    updatedSettings.yourEffectSettings.opacity = presetData['opacity'] ?? 0.5;
    // Apply other parameters
    updatedSettings.yourEffectSettings.effectAnimated = presetData['effectAnimated'] ?? false;
    updatedSettings.yourEffectSettings.animationSpeed = presetData['animationSpeed'] ?? 1.0;
    
    widget.onSettingsChanged(updatedSettings);
  }

  // Load presets for the current aspect
  Future<Map<String, dynamic>> _loadPresetsForAspect(ShaderAspect aspect) async {
    if (_cachedPresets.containsKey(aspect)) {
      return _cachedPresets[aspect]!;
    }
    
    // For now, return empty presets until we implement the actual loading
    _cachedPresets[aspect] = {};
    return _cachedPresets[aspect]!;
  }

  // Delete preset and update the UI
  Future<bool> _deletePresetAndUpdate(ShaderAspect aspect, String presetName) async {
    // For now, just simulate success
    _cachedPresets.remove(aspect);
    _refreshPresets();
    return true;
  }

  // Save current settings as a preset
  void _savePresetForAspect(ShaderAspect aspect, String presetName) {
    if (presetName.isEmpty) return;
    
    // Create preset data
    final presetData = {
      'effectEnabled': true,
      'opacity': widget.settings.yourEffectSettings.opacity,
      // Add your parameters
      'effectAnimated': widget.settings.yourEffectSettings.effectAnimated,
      'animationSpeed': widget.settings.yourEffectSettings.animationSpeed,
    };
    
    // For now, just store in our cache
    if (!_cachedPresets.containsKey(aspect)) {
      _cachedPresets[aspect] = {};
    }
    _cachedPresets[aspect]![presetName] = presetData;
    
    // Notify preset service
    final refreshService = PresetRefreshService();
    refreshService.refreshAspect(aspect);
    
    // Update refresh counter to trigger UI update
    _refreshPresets();
  }

  // Refresh presets
  void _refreshPresets() {
    setState(() {
      _refreshCounter++;
    });
  }
}
```

## 9. Add Panel to Effect Controls

Update `lib/shader_demo_v2/views/effect_controls.dart`:

```dart
// Add import
import '../widgets/your_effect_panel.dart';

// Add to aspect toggle bar
GlassAspectToggle(
  aspect: ShaderAspect.yourEffect,
  isEnabled: settings.yourEffectEnabled,
  isCurrentImageDark: isCurrentImageDark,
  onToggled: (aspect, enabled) =>
      _toggleAspect(aspect, enabled, controller),
  onTap: _selectAspect,
),

// Add to _toggleAspect method
case ShaderAspect.yourEffect:
  settings.yourEffectEnabled = enabled;
  break;

// Add to _buildAspectParameterSliders
if (_selectedAspect == ShaderAspect.yourEffect)
  YourEffectPanel(
    settings: controller.settings,
    onSettingsChanged: controller.updateSettings,
    sliderColor: sliderColor,
    context: context,
  ),
```

## 10. Update pubspec.yaml

Add your shader to the assets section in `pubspec.yaml`:

```yaml
flutter:
  shaders:
    - assets/shaders/your_effect.frag
```

## 11. Testing Your Shader

1. Make sure all files are saved
2. Restart the app to ensure the shader is properly loaded
3. Test the shader with different parameter values
4. Test animation if applicable
5. Test with different images to ensure compatibility

## Flutter Shader Coordinate System

Understanding Flutter's coordinate system is critical for shader development:

1. **FlutterFragCoord()**: Always use this function instead of `gl_FragCoord`. It handles the coordinate system differences between Flutter and OpenGL.

2. **UV Coordinates**: Calculate texture coordinates as:
   ```glsl
   vec2 uv = fragCoord/uResolution.xy;
   ```

3. **Pixel Coordinates**: For effects that need pixel-level precision (like crosshatching):
   ```glsl
   vec2 pixelCoord = fragCoord; // Already in pixel space
   ```

4. **Scaling Effects**: Scale your effects based on screen resolution to maintain consistent appearance:
   ```glsl
   float scale = min(uResolution.x, uResolution.y) / 800.0;
   float spacing = max(1.0, uLineSpacing * scale);
   ```

5. **Coordinate Origins**: 
   - Flutter's coordinate origin (0,0) is at the top-left
   - The Y-axis increases downward
   - Texture coordinates range from (0,0) at top-left to (1,1) at bottom-right

6. **Common Mistakes**:
   - Using `gl_FragCoord` directly (causes distortion)
   - Not using `#include <flutter/runtime_effect.glsl>`
   - Incorrect UV calculation leading to stretched or tiny images
   - Forgetting to scale effect parameters based on resolution

## Common Issues and Solutions

1. **Black Screen**: Check uniform order in shader and widget
2. **Distorted Image**: Ensure proper UV coordinates with `FlutterFragCoord()`
3. **No Effect Visible**: Check opacity and effect threshold values
4. **Shader Not Loading**: Verify asset path in `pubspec.yaml`
5. **Compilation Errors**: Check GLSL version and syntax
6. **Image in Top-Left Corner**: Incorrect UV calculation, use `fragCoord/uResolution.xy`
7. **Stretched Image**: Not accounting for aspect ratio, consider normalizing coordinates

## Best Practices

1. Follow the existing pattern for shaders and widgets
2. Use `FlutterFragCoord()` for proper coordinate handling
3. Always handle transparent pixels and text content
4. Provide fallback rendering in case of errors
5. Use appropriate scaling for parameters based on screen resolution
6. Keep shader logic simple and optimize for mobile performance
7. Add debug logging for troubleshooting
8. Test on different screen sizes and orientations