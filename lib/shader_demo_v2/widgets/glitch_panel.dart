import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/parameter_range.dart';
import '../controllers/animation_state_manager.dart';
import '../services/preset_refresh_service.dart';
import 'range_lockable_slider.dart';
import 'animation_controls.dart';
import 'enhanced_panel_header.dart';

class GlitchPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const GlitchPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<GlitchPanel> createState() => _GlitchPanelState();
}

class _GlitchPanelState extends State<GlitchPanel> {
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    // Ensure effect is enabled when panel is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.settings.glitchEnabled) {
        final updatedSettings = widget.settings;
        updatedSettings.glitchEnabled = true;
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
          aspect: ShaderAspect.glitch,
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
              RangeLockableSlider(
                label: 'Effect Opacity',
                range: widget.settings.glitchSettings.opacityRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults: ShaderSettings.defaults.glitchSettings.opacityRange,
                parameterId: ParameterIds.glitchOpacity,
                animationEnabled: widget.settings.glitchSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.glitchSettings.setOpacityRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Intensity slider
              RangeLockableSlider(
                label: 'Intensity',
                range: widget.settings.glitchSettings.intensityRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults: ShaderSettings.defaults.glitchSettings.intensityRange,
                parameterId: ParameterIds.glitchIntensity,
                animationEnabled: widget.settings.glitchSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.glitchSettings.setIntensityRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Frequency slider
              RangeLockableSlider(
                label: 'Frequency',
                range: widget.settings.glitchSettings.frequencyRange,
                min: 0.0,
                max: 2.0,
                divisions: 20,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${v.toStringAsFixed(1)}x',
                defaults: ShaderSettings.defaults.glitchSettings.frequencyRange,
                parameterId: ParameterIds.glitchSpeed,
                animationEnabled: widget.settings.glitchSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.glitchSettings.setFrequencyRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Block Size slider
              RangeLockableSlider(
                label: 'Block Size',
                range: widget.settings.glitchSettings.blockSizeRange,
                min: 0.01,
                max: 0.5,
                divisions: 49,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults: ShaderSettings.defaults.glitchSettings.blockSizeRange,
                parameterId: ParameterIds.glitchBlockSize,
                animationEnabled: widget.settings.glitchSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.glitchSettings.setBlockSizeRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Horizontal Slice Intensity slider
              RangeLockableSlider(
                label: 'Horizontal Slicing',
                range: widget
                    .settings
                    .glitchSettings
                    .horizontalSliceIntensityRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults: ShaderSettings
                    .defaults
                    .glitchSettings
                    .horizontalSliceIntensityRange,
                parameterId: ParameterIds.glitchHorizontalSliceIntensity,
                animationEnabled: widget.settings.glitchSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.glitchSettings
                      .setHorizontalSliceIntensityRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Vertical Slice Intensity slider
              RangeLockableSlider(
                label: 'Vertical Slicing',
                range:
                    widget.settings.glitchSettings.verticalSliceIntensityRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults: ShaderSettings
                    .defaults
                    .glitchSettings
                    .verticalSliceIntensityRange,
                parameterId: ParameterIds.glitchVerticalSliceIntensity,
                animationEnabled: widget.settings.glitchSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.glitchSettings.setVerticalSliceIntensityRange(
                    range,
                  );
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Animation toggle
              SwitchListTile(
                title: const Text('Enable Animation'),
                value: widget.settings.glitchSettings.effectAnimated,
                onChanged: _onAnimatedChanged,
                activeColor: widget.sliderColor,
              ),

              // Animation controls - only show when animation is enabled
              if (widget.settings.glitchSettings.effectAnimated)
                AnimationControls(
                  animationSpeed: widget.settings.glitchSettings.animationSpeed,
                  onSpeedChanged: _onAnimationSpeedChanged,
                  animationMode:
                      widget.settings.glitchSettings.effectAnimOptions.mode,
                  onModeChanged: _onAnimationModeChanged,
                  animationEasing:
                      widget.settings.glitchSettings.effectAnimOptions.easing,
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

  // Handle animation speed changes
  void _onAnimationSpeedChanged(double speed) {
    final updatedSettings = widget.settings;
    updatedSettings.glitchSettings.animationSpeed = speed;

    // Also update the speed in animation options
    updatedSettings.glitchSettings.effectAnimOptions = updatedSettings
        .glitchSettings
        .effectAnimOptions
        .copyWith(speed: speed);

    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation mode changes
  void _onAnimationModeChanged(AnimationMode mode) {
    final updatedSettings = widget.settings;
    updatedSettings.glitchSettings.effectAnimOptions = updatedSettings
        .glitchSettings
        .effectAnimOptions
        .copyWith(mode: mode);
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation easing changes
  void _onAnimationEasingChanged(AnimationEasing easing) {
    final updatedSettings = widget.settings;
    updatedSettings.glitchSettings.effectAnimOptions = updatedSettings
        .glitchSettings
        .effectAnimOptions
        .copyWith(easing: easing);
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation toggle
  void _onAnimatedChanged(bool isAnimated) {
    final updatedSettings = widget.settings;
    updatedSettings.glitchSettings.effectAnimated = isAnimated;
    widget.onSettingsChanged(updatedSettings);
  }

  // Reset settings to defaults
  void _resetEffect() {
    final updatedSettings = widget.settings;
    updatedSettings.glitchSettings.reset();
    widget.onSettingsChanged(updatedSettings);
  }

  // Apply preset
  void _applyPreset(Map<String, dynamic> presetData) {
    final updatedSettings = widget.settings;

    // Apply preset values
    updatedSettings.glitchEnabled = presetData['effectEnabled'] ?? true;
    updatedSettings.glitchSettings.setOpacityRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'opacityRange',
        valueKey: 'opacity',
        minKey: 'opacityMin',
        maxKey: 'opacityMax',
        currentKey: 'opacityCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: updatedSettings.glitchSettings.opacity,
      ),
    );
    updatedSettings.glitchSettings.setIntensityRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'intensityRange',
        valueKey: 'intensity',
        minKey: 'intensityMin',
        maxKey: 'intensityMax',
        currentKey: 'intensityCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: updatedSettings.glitchSettings.intensity,
      ),
    );
    updatedSettings.glitchSettings.setFrequencyRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'frequencyRange',
        valueKey: 'frequency',
        minKey: 'frequencyMin',
        maxKey: 'frequencyMax',
        currentKey: 'frequencyCurrent',
        hardMin: 0.0,
        hardMax: 2.0,
        fallbackValue: updatedSettings.glitchSettings.frequency,
      ),
    );
    updatedSettings.glitchSettings.setBlockSizeRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'blockSizeRange',
        valueKey: 'blockSize',
        minKey: 'blockSizeMin',
        maxKey: 'blockSizeMax',
        currentKey: 'blockSizeCurrent',
        hardMin: 0.01,
        hardMax: 0.5,
        fallbackValue: updatedSettings.glitchSettings.blockSize,
      ),
    );
    updatedSettings.glitchSettings.setHorizontalSliceIntensityRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'horizontalSliceIntensityRange',
        valueKey: 'horizontalSliceIntensity',
        minKey: 'horizontalSliceIntensityMin',
        maxKey: 'horizontalSliceIntensityMax',
        currentKey: 'horizontalSliceIntensityCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: updatedSettings.glitchSettings.horizontalSliceIntensity,
      ),
    );
    updatedSettings.glitchSettings.setVerticalSliceIntensityRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'verticalSliceIntensityRange',
        valueKey: 'verticalSliceIntensity',
        minKey: 'verticalSliceIntensityMin',
        maxKey: 'verticalSliceIntensityMax',
        currentKey: 'verticalSliceIntensityCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: updatedSettings.glitchSettings.verticalSliceIntensity,
      ),
    );
    updatedSettings.glitchSettings.effectAnimated =
        presetData['effectAnimated'] ?? false;
    updatedSettings.glitchSettings.animationSpeed =
        presetData['animationSpeed'] ?? 1.0;

    // Load animation options if available
    if (presetData['animOptions'] != null) {
      updatedSettings.glitchSettings.effectAnimOptions =
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
      // Existing scalar values for backward compatibility
      'effectEnabled': true,
      'opacity': widget.settings.glitchSettings.opacity,
      'intensity': widget.settings.glitchSettings.intensity,
      'frequency': widget.settings.glitchSettings.frequency,
      'blockSize': widget.settings.glitchSettings.blockSize,
      'horizontalSliceIntensity':
          widget.settings.glitchSettings.horizontalSliceIntensity,
      'verticalSliceIntensity':
          widget.settings.glitchSettings.verticalSliceIntensity,
      // New range values
      'opacityMin': widget.settings.glitchSettings.opacityRange.userMin,
      'opacityMax': widget.settings.glitchSettings.opacityRange.userMax,
      'opacityCurrent': widget.settings.glitchSettings.opacityRange.current,
      'opacityRange': widget.settings.glitchSettings.opacityRange.toMap(),
      'intensityMin': widget.settings.glitchSettings.intensityRange.userMin,
      'intensityMax': widget.settings.glitchSettings.intensityRange.userMax,
      'intensityCurrent': widget.settings.glitchSettings.intensityRange.current,
      'intensityRange': widget.settings.glitchSettings.intensityRange.toMap(),
      'frequencyMin': widget.settings.glitchSettings.frequencyRange.userMin,
      'frequencyMax': widget.settings.glitchSettings.frequencyRange.userMax,
      'frequencyCurrent': widget.settings.glitchSettings.frequencyRange.current,
      'frequencyRange': widget.settings.glitchSettings.frequencyRange.toMap(),
      'blockSizeMin': widget.settings.glitchSettings.blockSizeRange.userMin,
      'blockSizeMax': widget.settings.glitchSettings.blockSizeRange.userMax,
      'blockSizeCurrent': widget.settings.glitchSettings.blockSizeRange.current,
      'blockSizeRange': widget.settings.glitchSettings.blockSizeRange.toMap(),
      'horizontalSliceIntensityMin':
          widget.settings.glitchSettings.horizontalSliceIntensityRange.userMin,
      'horizontalSliceIntensityMax':
          widget.settings.glitchSettings.horizontalSliceIntensityRange.userMax,
      'horizontalSliceIntensityCurrent':
          widget.settings.glitchSettings.horizontalSliceIntensityRange.current,
      'horizontalSliceIntensityRange': widget
          .settings
          .glitchSettings
          .horizontalSliceIntensityRange
          .toMap(),
      'verticalSliceIntensityMin':
          widget.settings.glitchSettings.verticalSliceIntensityRange.userMin,
      'verticalSliceIntensityMax':
          widget.settings.glitchSettings.verticalSliceIntensityRange.userMax,
      'verticalSliceIntensityCurrent':
          widget.settings.glitchSettings.verticalSliceIntensityRange.current,
      'verticalSliceIntensityRange': widget
          .settings
          .glitchSettings
          .verticalSliceIntensityRange
          .toMap(),
      'effectAnimated': widget.settings.glitchSettings.effectAnimated,
      'animationSpeed': widget.settings.glitchSettings.animationSpeed,
      'animOptions': widget.settings.glitchSettings.effectAnimOptions.toMap(),
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
