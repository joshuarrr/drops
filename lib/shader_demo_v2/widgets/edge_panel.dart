import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/parameter_range.dart';
import '../services/preset_refresh_service.dart';
import '../controllers/animation_state_manager.dart';
import 'range_lockable_slider.dart';
import 'animation_controls.dart';
import 'enhanced_panel_header.dart';

class EdgePanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const EdgePanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<EdgePanel> createState() => _EdgePanelState();
}

class _EdgePanelState extends State<EdgePanel> {
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnhancedPanelHeader(
          aspect: ShaderAspect.edge,
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
            // Edge effect only applies to images for now
          },
          onApplyToTextChanged: (value) {
            // Edge effect only applies to images for now
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // Opacity slider
              RangeLockableSlider(
                label: 'Edge Opacity',
                range: widget.settings.edgeSettings.opacityRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults: ShaderSettings.defaults.edgeSettings.opacityRange,
                parameterId: ParameterIds.edgeOpacity,
                animationEnabled: widget.settings.edgeSettings.edgeAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.edgeSettings.setOpacityRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Edge Intensity slider
              RangeLockableSlider(
                label: 'Edge Intensity',
                range: widget.settings.edgeSettings.edgeIntensityRange,
                min: 0.1,
                max: 5.0,
                divisions: 49,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(1),
                defaults:
                    ShaderSettings.defaults.edgeSettings.edgeIntensityRange,
                parameterId: ParameterIds.edgeIntensity,
                animationEnabled: widget.settings.edgeSettings.edgeAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.edgeSettings.setEdgeIntensityRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Edge Thickness slider
              RangeLockableSlider(
                label: 'Edge Thickness',
                range: widget.settings.edgeSettings.edgeThicknessRange,
                min: 0.1,
                max: 5.0,
                divisions: 49,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(1),
                defaults:
                    ShaderSettings.defaults.edgeSettings.edgeThicknessRange,
                parameterId: ParameterIds.edgeThickness,
                animationEnabled: widget.settings.edgeSettings.edgeAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.edgeSettings.setEdgeThicknessRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Edge Color slider
              RangeLockableSlider(
                label: 'Edge Color',
                range: widget.settings.edgeSettings.edgeColorRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => _getEdgeColorLabel(v),
                defaults: ShaderSettings.defaults.edgeSettings.edgeColorRange,
                parameterId: ParameterIds.edgeColor,
                animationEnabled: widget.settings.edgeSettings.edgeAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.edgeSettings.setEdgeColorRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Animation toggle
              SwitchListTile(
                title: const Text('Enable Animation'),
                value: widget.settings.edgeSettings.edgeAnimated,
                onChanged: _onAnimatedChanged,
                activeColor: widget.sliderColor,
              ),

              // Animation controls - only show when animation is enabled
              if (widget.settings.edgeSettings.edgeAnimated)
                AnimationControls(
                  animationSpeed: widget.settings.edgeSettings.animationSpeed,
                  onSpeedChanged: _onAnimationSpeedChanged,
                  animationMode:
                      widget.settings.edgeSettings.edgeAnimOptions.mode,
                  onModeChanged: _onAnimationModeChanged,
                  animationEasing:
                      widget.settings.edgeSettings.edgeAnimOptions.easing,
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

  // Helper to get edge color label
  String _getEdgeColorLabel(double value) {
    if (value < 0.33) {
      return 'Black';
    } else if (value < 0.67) {
      return 'Original';
    } else {
      return 'White';
    }
  }

  // Handle animation toggle
  void _onAnimatedChanged(bool isAnimated) {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.edgeAnimated = isAnimated;
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation speed changes
  void _onAnimationSpeedChanged(double speed) {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.animationSpeed = speed;

    // Also update the speed in animation options
    updatedSettings.edgeSettings.edgeAnimOptions = updatedSettings
        .edgeSettings
        .edgeAnimOptions
        .copyWith(speed: speed);

    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation mode changes
  void _onAnimationModeChanged(AnimationMode mode) {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.edgeAnimOptions = updatedSettings
        .edgeSettings
        .edgeAnimOptions
        .copyWith(mode: mode);
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation easing changes
  void _onAnimationEasingChanged(AnimationEasing easing) {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.edgeAnimOptions = updatedSettings
        .edgeSettings
        .edgeAnimOptions
        .copyWith(easing: easing);
    widget.onSettingsChanged(updatedSettings);
  }

  // Reset settings to defaults
  void _resetEffect() {
    final updatedSettings = widget.settings;
    updatedSettings.edgeSettings.reset();
    widget.onSettingsChanged(updatedSettings);
  }

  // Apply preset
  void _applyPreset(Map<String, dynamic> presetData) {
    final updatedSettings = widget.settings;

    // Apply preset values
    updatedSettings.edgeEnabled = presetData['edgeEnabled'] ?? true;
    updatedSettings.edgeSettings.setOpacityRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'opacityRange',
        valueKey: 'opacity',
        minKey: 'opacityMin',
        maxKey: 'opacityMax',
        currentKey: 'opacityCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: updatedSettings.edgeSettings.opacity,
      ),
    );
    updatedSettings.edgeSettings.setEdgeIntensityRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'edgeIntensityRange',
        valueKey: 'edgeIntensity',
        minKey: 'edgeIntensityMin',
        maxKey: 'edgeIntensityMax',
        currentKey: 'edgeIntensityCurrent',
        hardMin: 0.1,
        hardMax: 5.0,
        fallbackValue: updatedSettings.edgeSettings.edgeIntensity,
      ),
    );
    updatedSettings.edgeSettings.setEdgeThicknessRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'edgeThicknessRange',
        valueKey: 'edgeThickness',
        minKey: 'edgeThicknessMin',
        maxKey: 'edgeThicknessMax',
        currentKey: 'edgeThicknessCurrent',
        hardMin: 0.1,
        hardMax: 5.0,
        fallbackValue: updatedSettings.edgeSettings.edgeThickness,
      ),
    );
    updatedSettings.edgeSettings.setEdgeColorRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'edgeColorRange',
        valueKey: 'edgeColor',
        minKey: 'edgeColorMin',
        maxKey: 'edgeColorMax',
        currentKey: 'edgeColorCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: updatedSettings.edgeSettings.edgeColor,
      ),
    );
    updatedSettings.edgeSettings.edgeAnimated =
        presetData['edgeAnimated'] ?? false;
    updatedSettings.edgeSettings.animationSpeed =
        presetData['animationSpeed'] ?? 1.0;

    // Load animation options if available
    if (presetData['animOptions'] != null) {
      updatedSettings.edgeSettings.edgeAnimOptions = AnimationOptions.fromMap(
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
      // Existing scalar values for backward compatibility
      'edgeEnabled': true,
      'opacity': widget.settings.edgeSettings.opacity,
      'edgeIntensity': widget.settings.edgeSettings.edgeIntensity,
      'edgeThickness': widget.settings.edgeSettings.edgeThickness,
      'edgeColor': widget.settings.edgeSettings.edgeColor,
      // New range values
      'opacityMin': widget.settings.edgeSettings.opacityRange.userMin,
      'opacityMax': widget.settings.edgeSettings.opacityRange.userMax,
      'opacityCurrent': widget.settings.edgeSettings.opacityRange.current,
      'opacityRange': widget.settings.edgeSettings.opacityRange.toMap(),
      'edgeIntensityMin':
          widget.settings.edgeSettings.edgeIntensityRange.userMin,
      'edgeIntensityMax':
          widget.settings.edgeSettings.edgeIntensityRange.userMax,
      'edgeIntensityCurrent':
          widget.settings.edgeSettings.edgeIntensityRange.current,
      'edgeIntensityRange': widget.settings.edgeSettings.edgeIntensityRange
          .toMap(),
      'edgeThicknessMin':
          widget.settings.edgeSettings.edgeThicknessRange.userMin,
      'edgeThicknessMax':
          widget.settings.edgeSettings.edgeThicknessRange.userMax,
      'edgeThicknessCurrent':
          widget.settings.edgeSettings.edgeThicknessRange.current,
      'edgeThicknessRange': widget.settings.edgeSettings.edgeThicknessRange
          .toMap(),
      'edgeColorMin': widget.settings.edgeSettings.edgeColorRange.userMin,
      'edgeColorMax': widget.settings.edgeSettings.edgeColorRange.userMax,
      'edgeColorCurrent': widget.settings.edgeSettings.edgeColorRange.current,
      'edgeColorRange': widget.settings.edgeSettings.edgeColorRange.toMap(),
      'edgeAnimated': widget.settings.edgeSettings.edgeAnimated,
      'animationSpeed': widget.settings.edgeSettings.animationSpeed,
      'animOptions': widget.settings.edgeSettings.edgeAnimOptions.toMap(),
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

  ParameterRange _rangeFromPreset(
    Map<String, dynamic> presetData, {
    required String rangeKey,
    required String valueKey,
    required String minKey,
    required String maxKey,
    required String currentKey,
    required double hardMin,
    required double hardMax,
    required double fallbackValue,
  }) {
    final double fallback = _readDouble(
      presetData[valueKey],
      fallbackValue,
    ).clamp(hardMin, hardMax).toDouble();

    final dynamic payload = presetData[rangeKey];
    if (payload is Map<String, dynamic>) {
      return ParameterRange.fromMap(
        Map<String, dynamic>.from(payload),
        hardMin: hardMin,
        hardMax: hardMax,
        fallbackValue: fallback,
      );
    }

    final double userMin = _readDouble(
      presetData[minKey],
      hardMin,
    ).clamp(hardMin, hardMax).toDouble();
    final double userMax = _readDouble(
      presetData[maxKey],
      fallback,
    ).clamp(hardMin, hardMax).toDouble();
    final double current = _readDouble(
      presetData[currentKey],
      fallback,
    ).clamp(hardMin, hardMax).toDouble();

    return ParameterRange(
      hardMin: hardMin,
      hardMax: hardMax,
      initialValue: current,
      userMin: userMin,
      userMax: userMax,
    );
  }

  double _readDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return fallback;
  }
}
