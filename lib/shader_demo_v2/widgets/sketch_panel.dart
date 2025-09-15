import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import '../services/preset_refresh_service.dart';
import 'lockable_slider.dart';
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
              LockableSlider(
                label: 'Image Opacity',
                value: widget.settings.sketchSettings.imageOpacity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.sketchSettings.imageOpacity * 100).round()}%',
                onChanged: (value) => _onImageOpacityChanged(value),
                activeColor: widget.sliderColor,
                parameterId: 'sketch_image_opacity',
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                defaultValue: 1.0,
              ),

              const SizedBox(height: 16),

              // Sketch Opacity slider
              LockableSlider(
                label: 'Sketch Opacity',
                value: widget.settings.sketchSettings.opacity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.sketchSettings.opacity * 100).round()}%',
                onChanged: (value) => _onOpacityChanged(value),
                activeColor: widget.sliderColor,
                parameterId: 'sketch_opacity',
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                defaultValue: 0.8,
              ),

              const SizedBox(height: 16),

              // Luminance threshold 1 slider
              LockableSlider(
                label: 'Luminance Threshold 1',
                value: widget.settings.sketchSettings.lumThreshold1,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.sketchSettings.lumThreshold1 * 100).round()}%',
                onChanged: (value) => _onLumThreshold1Changed(value),
                activeColor: widget.sliderColor,
                parameterId: 'sketch_lum_threshold1',
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                defaultValue: 0.8,
              ),

              const SizedBox(height: 16),

              // Luminance threshold 2 slider
              LockableSlider(
                label: 'Luminance Threshold 2',
                value: widget.settings.sketchSettings.lumThreshold2,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.sketchSettings.lumThreshold2 * 100).round()}%',
                onChanged: (value) => _onLumThreshold2Changed(value),
                activeColor: widget.sliderColor,
                parameterId: 'sketch_lum_threshold2',
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                defaultValue: 0.6,
              ),

              const SizedBox(height: 16),

              // Luminance threshold 3 slider
              LockableSlider(
                label: 'Luminance Threshold 3',
                value: widget.settings.sketchSettings.lumThreshold3,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.sketchSettings.lumThreshold3 * 100).round()}%',
                onChanged: (value) => _onLumThreshold3Changed(value),
                activeColor: widget.sliderColor,
                parameterId: 'sketch_lum_threshold3',
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                defaultValue: 0.4,
              ),

              const SizedBox(height: 16),

              // Luminance threshold 4 slider
              LockableSlider(
                label: 'Luminance Threshold 4',
                value: widget.settings.sketchSettings.lumThreshold4,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.sketchSettings.lumThreshold4 * 100).round()}%',
                onChanged: (value) => _onLumThreshold4Changed(value),
                activeColor: widget.sliderColor,
                parameterId: 'sketch_lum_threshold4',
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                defaultValue: 0.2,
              ),

              const SizedBox(height: 16),

              // Hatch Y Offset slider
              LockableSlider(
                label: 'Hatch Y Offset',
                value: widget.settings.sketchSettings.hatchYOffset,
                min: 0.0,
                max: 50.0,
                divisions: 100,
                displayValue:
                    '${widget.settings.sketchSettings.hatchYOffset.round()}px',
                onChanged: (value) => _onHatchYOffsetChanged(value),
                activeColor: widget.sliderColor,
                parameterId: 'sketch_hatch_y_offset',
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                defaultValue: 0.0,
              ),

              const SizedBox(height: 16),

              // Line Spacing slider
              LockableSlider(
                label: 'Line Spacing',
                value: widget.settings.sketchSettings.lineSpacing,
                min: 5.0,
                max: 50.0,
                divisions: 90,
                displayValue:
                    '${widget.settings.sketchSettings.lineSpacing.round()}px',
                onChanged: (value) => _onLineSpacingChanged(value),
                activeColor: widget.sliderColor,
                parameterId: 'sketch_line_spacing',
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                defaultValue: 15.0,
              ),

              const SizedBox(height: 16),

              // Line Thickness slider
              LockableSlider(
                label: 'Line Thickness',
                value: widget.settings.sketchSettings.lineThickness,
                min: 0.5,
                max: 5.0,
                divisions: 45,
                displayValue:
                    '${widget.settings.sketchSettings.lineThickness.toStringAsFixed(1)}px',
                onChanged: (value) => _onLineThicknessChanged(value),
                activeColor: widget.sliderColor,
                parameterId: 'sketch_line_thickness',
                animationEnabled: widget.settings.sketchSettings.sketchAnimated,
                defaultValue: 1.5,
              ),

              const SizedBox(height: 16),

              // Animation controls
              AnimationControls(
                animationSpeed: widget.settings.sketchSettings.animationSpeed,
                onSpeedChanged: _onAnimationSpeedChanged,
                animationMode: AnimationMode.pulse,
                onModeChanged: (mode) {}, // Sketch only supports pulse mode
                animationEasing: AnimationEasing.linear,
                onEasingChanged:
                    (easing) {}, // Sketch only supports linear easing
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
  void _onImageOpacityChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.imageOpacity = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onOpacityChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.opacity = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onLumThreshold1Changed(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.lumThreshold1 = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onLumThreshold2Changed(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.lumThreshold2 = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onLumThreshold3Changed(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.lumThreshold3 = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onLumThreshold4Changed(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.lumThreshold4 = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onHatchYOffsetChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.hatchYOffset = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onLineSpacingChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.lineSpacing = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onLineThicknessChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.lineThickness = value;
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation speed changes
  void _onAnimationSpeedChanged(double speed) {
    final updatedSettings = widget.settings;
    updatedSettings.sketchSettings.animationSpeed = speed;
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
