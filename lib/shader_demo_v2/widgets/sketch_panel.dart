import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../services/preset_refresh_service.dart';
import '../controllers/animation_state_manager.dart';
import 'range_lockable_slider.dart';
import 'animation_controls.dart';
import 'enhanced_panel_header.dart';

class SketchPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const SketchPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<SketchPanel> createState() => _SketchPanelState();
}

class _SketchPanelState extends State<SketchPanel> {
  // Add static fields for presets
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    // Ensure sketch effect is enabled when panel is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.settings.sketchEnabled) {
        final updatedSettings = widget.settings;
        updatedSettings.sketchEnabled = true;
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
          aspect: ShaderAspect.sketch,
          onPresetSelected: _applyPreset,
          onReset: _resetSketch,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: true, // Always apply to image for sketch effect
          applyToText: false, // Never apply to text for sketch effect
          onApplyToImageChanged: (value) {
            // Sketch effect always applies to image
          },
          onApplyToTextChanged: (value) {
            // Sketch effect never applies to text
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Image Opacity slider
              RangeLockableSlider(
                label: 'Image Opacity',
                range: widget.settings.sketchSettings.imageOpacityRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults:
                    ShaderSettings.defaults.sketchSettings.imageOpacityRange,
                parameterId: ParameterIds.sketchImageOpacity,
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.sketchSettings.setImageOpacityRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Sketch Opacity slider
              RangeLockableSlider(
                label: 'Sketch Opacity',
                range: widget.settings.sketchSettings.opacityRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults: ShaderSettings.defaults.sketchSettings.opacityRange,
                parameterId: ParameterIds.sketchOpacity,
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.sketchSettings.setOpacityRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Luminance threshold 1 slider
              RangeLockableSlider(
                label: 'Luminance Threshold 1',
                range: widget.settings.sketchSettings.lumThreshold1Range,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults:
                    ShaderSettings.defaults.sketchSettings.lumThreshold1Range,
                parameterId: ParameterIds.sketchLumThreshold1,
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.sketchSettings.setLumThreshold1Range(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Luminance threshold 2 slider
              RangeLockableSlider(
                label: 'Luminance Threshold 2',
                range: widget.settings.sketchSettings.lumThreshold2Range,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults:
                    ShaderSettings.defaults.sketchSettings.lumThreshold2Range,
                parameterId: ParameterIds.sketchLumThreshold2,
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.sketchSettings.setLumThreshold2Range(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Luminance threshold 3 slider
              RangeLockableSlider(
                label: 'Luminance Threshold 3',
                range: widget.settings.sketchSettings.lumThreshold3Range,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults:
                    ShaderSettings.defaults.sketchSettings.lumThreshold3Range,
                parameterId: ParameterIds.sketchLumThreshold3,
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.sketchSettings.setLumThreshold3Range(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Luminance threshold 4 slider
              RangeLockableSlider(
                label: 'Luminance Threshold 4',
                range: widget.settings.sketchSettings.lumThreshold4Range,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults:
                    ShaderSettings.defaults.sketchSettings.lumThreshold4Range,
                parameterId: ParameterIds.sketchLumThreshold4,
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.sketchSettings.setLumThreshold4Range(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Hatch Y Offset slider
              RangeLockableSlider(
                label: 'Hatch Y Offset',
                range: widget.settings.sketchSettings.hatchYOffsetRange,
                min: 0.0,
                max: 50.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${v.round()}px',
                defaults:
                    ShaderSettings.defaults.sketchSettings.hatchYOffsetRange,
                parameterId: ParameterIds.sketchHatchYOffset,
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.sketchSettings.setHatchYOffsetRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Line Spacing slider
              RangeLockableSlider(
                label: 'Line Spacing',
                range: widget.settings.sketchSettings.lineSpacingRange,
                min: 5.0,
                max: 50.0,
                divisions: 90,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${v.round()}px',
                defaults:
                    ShaderSettings.defaults.sketchSettings.lineSpacingRange,
                parameterId: ParameterIds.sketchLineSpacing,
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.sketchSettings.setLineSpacingRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Line Thickness slider
              RangeLockableSlider(
                label: 'Line Thickness',
                range: widget.settings.sketchSettings.lineThicknessRange,
                min: 0.5,
                max: 5.0,
                divisions: 45,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${v.toStringAsFixed(1)}px',
                defaults:
                    ShaderSettings.defaults.sketchSettings.lineThicknessRange,
                parameterId: ParameterIds.sketchLineThickness,
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.sketchSettings.setLineThicknessRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Animation toggle
              SwitchListTile(
                title: const Text('Enable Animation'),
                value: widget.settings.sketchSettings.sketchAnimated,
                onChanged: _onAnimatedChanged,
                activeColor: widget.sliderColor,
              ),

              // Animation controls - only show when animation is enabled
              if (widget.settings.sketchSettings.sketchAnimated)
                AnimationControls(
                  animationSpeed: widget.settings.sketchSettings.animationSpeed,
                  onSpeedChanged: _onAnimationSpeedChanged,
                  animationMode:
                      widget.settings.sketchSettings.sketchAnimOptions.mode,
                  onModeChanged: _onAnimationModeChanged,
                  animationEasing:
                      widget.settings.sketchSettings.sketchAnimOptions.easing,
                  onEasingChanged: _onAnimationEasingChanged,
                  sliderColor: widget.sliderColor,
                ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }

  // Handle animation toggle
  void _onAnimatedChanged(bool isAnimated) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.sketchAnimated = isAnimated;
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation speed changes
  void _onAnimationSpeedChanged(double speed) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.animationSpeed = speed;

    // Also update the speed in animation options
    updatedSettings.sketchSettings.sketchAnimOptions = updatedSettings
        .sketchSettings
        .sketchAnimOptions
        .copyWith(speed: speed);

    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation mode changes
  void _onAnimationModeChanged(AnimationMode mode) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.sketchAnimOptions = updatedSettings
        .sketchSettings
        .sketchAnimOptions
        .copyWith(mode: mode);
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation easing changes
  void _onAnimationEasingChanged(AnimationEasing easing) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.sketchAnimOptions = updatedSettings
        .sketchSettings
        .sketchAnimOptions
        .copyWith(easing: easing);
    widget.onSettingsChanged(updatedSettings);
  }

  // Reset settings to defaults
  void _resetSketch() {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.reset();
    widget.onSettingsChanged(updatedSettings);
  }

  // Apply preset
  void _applyPreset(Map<String, dynamic> presetData) {
    final updatedSettings = widget.settings;

    // Apply preset values
    updatedSettings.sketchEnabled = presetData['sketchEnabled'] ?? true;
    updatedSettings.sketchSettings.opacity = presetData['opacity'] ?? 0.8;
    updatedSettings.sketchSettings.imageOpacity =
        presetData['imageOpacity'] ?? 1.0;
    updatedSettings.sketchSettings.lumThreshold1 =
        presetData['lumThreshold1'] ?? 0.8;
    updatedSettings.sketchSettings.lumThreshold2 =
        presetData['lumThreshold2'] ?? 0.6;
    updatedSettings.sketchSettings.lumThreshold3 =
        presetData['lumThreshold3'] ?? 0.4;
    updatedSettings.sketchSettings.lumThreshold4 =
        presetData['lumThreshold4'] ?? 0.2;
    updatedSettings.sketchSettings.hatchYOffset =
        presetData['hatchYOffset'] ?? 0.0;
    updatedSettings.sketchSettings.lineSpacing =
        presetData['lineSpacing'] ?? 15.0;
    updatedSettings.sketchSettings.lineThickness =
        presetData['lineThickness'] ?? 1.5;
    updatedSettings.sketchSettings.sketchAnimated =
        presetData['sketchAnimated'] ?? false;
    updatedSettings.sketchSettings.animationSpeed =
        presetData['animationSpeed'] ?? 1.0;

    // Load animation options if available
    if (presetData['animOptions'] != null) {
      updatedSettings.sketchSettings.sketchAnimOptions =
          AnimationOptions.fromMap(
            Map<String, dynamic>.from(presetData['animOptions']),
          );
    }

    widget.onSettingsChanged(updatedSettings);
  }

  // Load presets for the current aspect
  Future<Map<String, dynamic>> _loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    if (_cachedPresets.containsKey(aspect)) {
      return _cachedPresets[aspect]!;
    }

    // For now, return empty presets until we implement the actual loading
    _cachedPresets[aspect] = {};
    return _cachedPresets[aspect]!;
  }

  // Delete preset and update the UI
  Future<bool> _deletePresetAndUpdate(
    ShaderAspect aspect,
    String presetName,
  ) async {
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
      'sketchEnabled': true,
      'opacity': widget.settings.sketchSettings.opacity,
      'imageOpacity': widget.settings.sketchSettings.imageOpacity,
      'lumThreshold1': widget.settings.sketchSettings.lumThreshold1,
      'lumThreshold2': widget.settings.sketchSettings.lumThreshold2,
      'lumThreshold3': widget.settings.sketchSettings.lumThreshold3,
      'lumThreshold4': widget.settings.sketchSettings.lumThreshold4,
      'hatchYOffset': widget.settings.sketchSettings.hatchYOffset,
      'lineSpacing': widget.settings.sketchSettings.lineSpacing,
      'lineThickness': widget.settings.sketchSettings.lineThickness,
      'sketchAnimated': widget.settings.sketchSettings.sketchAnimated,
      'animationSpeed': widget.settings.sketchSettings.animationSpeed,
      'animOptions': widget.settings.sketchSettings.sketchAnimOptions.toMap(),
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
