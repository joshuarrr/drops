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

class VHSPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const VHSPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<VHSPanel> createState() => _VHSPanelState();
}

class _VHSPanelState extends State<VHSPanel> {
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    // Ensure effect is enabled when panel is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.settings.vhsEnabled) {
        final updatedSettings = widget.settings;
        updatedSettings.vhsEnabled = true;
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
          aspect: ShaderAspect.vhs,
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
                range: widget.settings.vhsSettings.opacityRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults: ShaderSettings.defaults.vhsSettings.opacityRange,
                parameterId: ParameterIds.vhsOpacity,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.vhsSettings.setOpacityRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Noise Intensity slider
              RangeLockableSlider(
                label: 'Noise Intensity',
                range: widget.settings.vhsSettings.noiseIntensityRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults:
                    ShaderSettings.defaults.vhsSettings.noiseIntensityRange,
                parameterId: ParameterIds.vhsNoiseIntensity,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.vhsSettings.setNoiseIntensityRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Field Lines slider
              RangeLockableSlider(
                label: 'Field Lines',
                range: widget.settings.vhsSettings.fieldLinesRange,
                min: 0.0,
                max: 400.0,
                divisions: 400,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${v.round()}',
                defaults: ShaderSettings.defaults.vhsSettings.fieldLinesRange,
                parameterId: ParameterIds.vhsFieldLines,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.vhsSettings.setFieldLinesRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Horizontal Wave Strength slider
              RangeLockableSlider(
                label: 'Wave Strength',
                range: widget.settings.vhsSettings.horizontalWaveStrengthRange,
                min: 0.0,
                max: 0.5,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults: ShaderSettings
                    .defaults
                    .vhsSettings
                    .horizontalWaveStrengthRange,
                parameterId: ParameterIds.vhsHorizontalWaveStrength,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.vhsSettings.setHorizontalWaveStrengthRange(
                    range,
                  );
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Horizontal Wave Screen Size slider
              RangeLockableSlider(
                label: 'Wave Screen Size',
                range:
                    widget.settings.vhsSettings.horizontalWaveScreenSizeRange,
                min: 10.0,
                max: 200.0,
                divisions: 190,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${v.round()}',
                defaults: ShaderSettings
                    .defaults
                    .vhsSettings
                    .horizontalWaveScreenSizeRange,
                parameterId: ParameterIds.vhsHorizontalWaveScreenSize,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.vhsSettings.setHorizontalWaveScreenSizeRange(
                    range,
                  );
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Horizontal Wave Vertical Size slider
              RangeLockableSlider(
                label: 'Wave Vertical Size',
                range:
                    widget.settings.vhsSettings.horizontalWaveVerticalSizeRange,
                min: 10.0,
                max: 300.0,
                divisions: 290,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${v.round()}',
                defaults: ShaderSettings
                    .defaults
                    .vhsSettings
                    .horizontalWaveVerticalSizeRange,
                parameterId: ParameterIds.vhsHorizontalWaveVerticalSize,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.vhsSettings
                      .setHorizontalWaveVerticalSizeRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Dotted Noise Strength slider
              RangeLockableSlider(
                label: 'Dotted Noise',
                range: widget.settings.vhsSettings.dottedNoiseStrengthRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 100).round()}%',
                defaults: ShaderSettings
                    .defaults
                    .vhsSettings
                    .dottedNoiseStrengthRange,
                parameterId: ParameterIds.vhsDottedNoiseStrength,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.vhsSettings.setDottedNoiseStrengthRange(
                    range,
                  );
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Horizontal Distortion Strength slider
              RangeLockableSlider(
                label: 'Distortion Strength',
                range: widget
                    .settings
                    .vhsSettings
                    .horizontalDistortionStrengthRange,
                min: 0.0,
                max: 0.02,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => '${(v * 10000).round()}',
                defaults: ShaderSettings
                    .defaults
                    .vhsSettings
                    .horizontalDistortionStrengthRange,
                parameterId: ParameterIds.vhsHorizontalDistortionStrength,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.vhsSettings
                      .setHorizontalDistortionStrengthRange(range);
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              const SizedBox(height: 16),

              // Animation toggle
              SwitchListTile(
                title: const Text('Enable Animation'),
                value: widget.settings.vhsSettings.effectAnimated,
                onChanged: _onAnimatedChanged,
                activeColor: widget.sliderColor,
              ),

              // Animation controls - only show when animation is enabled
              if (widget.settings.vhsSettings.effectAnimated)
                AnimationControls(
                  animationSpeed: widget.settings.vhsSettings.animationSpeed,
                  onSpeedChanged: _onAnimationSpeedChanged,
                  animationMode:
                      widget.settings.vhsSettings.effectAnimOptions.mode,
                  onModeChanged: _onAnimationModeChanged,
                  animationEasing:
                      widget.settings.vhsSettings.effectAnimOptions.easing,
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
    updatedSettings.vhsSettings.animationSpeed = speed;

    // Also update the speed in animation options
    updatedSettings.vhsSettings.effectAnimOptions = updatedSettings
        .vhsSettings
        .effectAnimOptions
        .copyWith(speed: speed);

    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation mode changes
  void _onAnimationModeChanged(AnimationMode mode) {
    final updatedSettings = widget.settings;
    updatedSettings.vhsSettings.effectAnimOptions = updatedSettings
        .vhsSettings
        .effectAnimOptions
        .copyWith(mode: mode);
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation easing changes
  void _onAnimationEasingChanged(AnimationEasing easing) {
    final updatedSettings = widget.settings;
    updatedSettings.vhsSettings.effectAnimOptions = updatedSettings
        .vhsSettings
        .effectAnimOptions
        .copyWith(easing: easing);
    widget.onSettingsChanged(updatedSettings);
  }

  // Handle animation toggle
  void _onAnimatedChanged(bool isAnimated) {
    final updatedSettings = widget.settings;
    updatedSettings.vhsSettings.effectAnimated = isAnimated;
    widget.onSettingsChanged(updatedSettings);
  }

  // Reset settings to defaults
  void _resetEffect() {
    final updatedSettings = widget.settings;
    updatedSettings.vhsSettings.reset();
    widget.onSettingsChanged(updatedSettings);
  }

  // Apply preset
  void _applyPreset(Map<String, dynamic> presetData) {
    final updatedSettings = widget.settings;

    // Apply preset values
    updatedSettings.vhsEnabled = presetData['effectEnabled'] ?? true;

    // Apply range data if available, otherwise fall back to legacy values
    _applyRangeFromPreset(
      updatedSettings.vhsSettings.opacityRange,
      presetData,
      'opacity',
      0.5,
    );
    _applyRangeFromPreset(
      updatedSettings.vhsSettings.noiseIntensityRange,
      presetData,
      'noiseIntensity',
      0.7,
    );
    _applyRangeFromPreset(
      updatedSettings.vhsSettings.fieldLinesRange,
      presetData,
      'fieldLines',
      240.0,
    );
    _applyRangeFromPreset(
      updatedSettings.vhsSettings.horizontalWaveStrengthRange,
      presetData,
      'horizontalWaveStrength',
      0.15,
    );
    _applyRangeFromPreset(
      updatedSettings.vhsSettings.horizontalWaveScreenSizeRange,
      presetData,
      'horizontalWaveScreenSize',
      50.0,
    );
    _applyRangeFromPreset(
      updatedSettings.vhsSettings.horizontalWaveVerticalSizeRange,
      presetData,
      'horizontalWaveVerticalSize',
      100.0,
    );
    _applyRangeFromPreset(
      updatedSettings.vhsSettings.dottedNoiseStrengthRange,
      presetData,
      'dottedNoiseStrength',
      0.2,
    );
    _applyRangeFromPreset(
      updatedSettings.vhsSettings.horizontalDistortionStrengthRange,
      presetData,
      'horizontalDistortionStrength',
      0.0087,
    );

    updatedSettings.vhsSettings.effectAnimated =
        presetData['effectAnimated'] ?? false;
    updatedSettings.vhsSettings.animationSpeed =
        presetData['animationSpeed'] ?? 1.0;

    // Load animation options if available
    if (presetData['animOptions'] != null) {
      updatedSettings.vhsSettings.effectAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['animOptions']),
      );
    }

    widget.onSettingsChanged(updatedSettings);
  }

  void _applyRangeFromPreset(
    ParameterRange range,
    Map<String, dynamic> presetData,
    String key,
    double fallback,
  ) {
    final value = presetData[key] ?? fallback;
    final min = presetData['${key}Min'] ?? 0.0;
    final max = presetData['${key}Max'] ?? value;
    final current = presetData['${key}Current'] ?? value;

    range
      ..setUserMin(min)
      ..setUserMax(max)
      ..setCurrent(current, syncUserMax: false);
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
      'effectEnabled': true,
      'opacity': widget.settings.vhsSettings.opacity,
      'opacityMin': widget.settings.vhsSettings.opacityRange.userMin,
      'opacityMax': widget.settings.vhsSettings.opacityRange.userMax,
      'opacityCurrent': widget.settings.vhsSettings.opacityRange.current,
      'opacityRange': widget.settings.vhsSettings.opacityRange.toMap(),
      'noiseIntensity': widget.settings.vhsSettings.noiseIntensity,
      'noiseIntensityMin':
          widget.settings.vhsSettings.noiseIntensityRange.userMin,
      'noiseIntensityMax':
          widget.settings.vhsSettings.noiseIntensityRange.userMax,
      'noiseIntensityCurrent':
          widget.settings.vhsSettings.noiseIntensityRange.current,
      'noiseIntensityRange': widget.settings.vhsSettings.noiseIntensityRange
          .toMap(),
      'fieldLines': widget.settings.vhsSettings.fieldLines,
      'fieldLinesMin': widget.settings.vhsSettings.fieldLinesRange.userMin,
      'fieldLinesMax': widget.settings.vhsSettings.fieldLinesRange.userMax,
      'fieldLinesCurrent': widget.settings.vhsSettings.fieldLinesRange.current,
      'fieldLinesRange': widget.settings.vhsSettings.fieldLinesRange.toMap(),
      'horizontalWaveStrength':
          widget.settings.vhsSettings.horizontalWaveStrength,
      'horizontalWaveStrengthMin':
          widget.settings.vhsSettings.horizontalWaveStrengthRange.userMin,
      'horizontalWaveStrengthMax':
          widget.settings.vhsSettings.horizontalWaveStrengthRange.userMax,
      'horizontalWaveStrengthCurrent':
          widget.settings.vhsSettings.horizontalWaveStrengthRange.current,
      'horizontalWaveStrengthRange': widget
          .settings
          .vhsSettings
          .horizontalWaveStrengthRange
          .toMap(),
      'horizontalWaveScreenSize':
          widget.settings.vhsSettings.horizontalWaveScreenSize,
      'horizontalWaveScreenSizeMin':
          widget.settings.vhsSettings.horizontalWaveScreenSizeRange.userMin,
      'horizontalWaveScreenSizeMax':
          widget.settings.vhsSettings.horizontalWaveScreenSizeRange.userMax,
      'horizontalWaveScreenSizeCurrent':
          widget.settings.vhsSettings.horizontalWaveScreenSizeRange.current,
      'horizontalWaveScreenSizeRange': widget
          .settings
          .vhsSettings
          .horizontalWaveScreenSizeRange
          .toMap(),
      'horizontalWaveVerticalSize':
          widget.settings.vhsSettings.horizontalWaveVerticalSize,
      'horizontalWaveVerticalSizeMin':
          widget.settings.vhsSettings.horizontalWaveVerticalSizeRange.userMin,
      'horizontalWaveVerticalSizeMax':
          widget.settings.vhsSettings.horizontalWaveVerticalSizeRange.userMax,
      'horizontalWaveVerticalSizeCurrent':
          widget.settings.vhsSettings.horizontalWaveVerticalSizeRange.current,
      'horizontalWaveVerticalSizeRange': widget
          .settings
          .vhsSettings
          .horizontalWaveVerticalSizeRange
          .toMap(),
      'dottedNoiseStrength': widget.settings.vhsSettings.dottedNoiseStrength,
      'dottedNoiseStrengthMin':
          widget.settings.vhsSettings.dottedNoiseStrengthRange.userMin,
      'dottedNoiseStrengthMax':
          widget.settings.vhsSettings.dottedNoiseStrengthRange.userMax,
      'dottedNoiseStrengthCurrent':
          widget.settings.vhsSettings.dottedNoiseStrengthRange.current,
      'dottedNoiseStrengthRange': widget
          .settings
          .vhsSettings
          .dottedNoiseStrengthRange
          .toMap(),
      'horizontalDistortionStrength':
          widget.settings.vhsSettings.horizontalDistortionStrength,
      'horizontalDistortionStrengthMin':
          widget.settings.vhsSettings.horizontalDistortionStrengthRange.userMin,
      'horizontalDistortionStrengthMax':
          widget.settings.vhsSettings.horizontalDistortionStrengthRange.userMax,
      'horizontalDistortionStrengthCurrent':
          widget.settings.vhsSettings.horizontalDistortionStrengthRange.current,
      'horizontalDistortionStrengthRange': widget
          .settings
          .vhsSettings
          .horizontalDistortionStrengthRange
          .toMap(),
      'effectAnimated': widget.settings.vhsSettings.effectAnimated,
      'animationSpeed': widget.settings.vhsSettings.animationSpeed,
      'animOptions': widget.settings.vhsSettings.effectAnimOptions.toMap(),
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
