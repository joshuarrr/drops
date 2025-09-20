import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../controllers/animation_state_manager.dart';
import '../services/preset_refresh_service.dart';
import 'lockable_slider.dart';
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
              LockableSlider(
                label: 'Effect Opacity',
                value: widget.settings.vhsSettings.opacity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.vhsSettings.opacity * 100).round()}%',
                onChanged: (value) => _onOpacityChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.vhsOpacity,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                defaultValue: 0.5,
              ),

              const SizedBox(height: 16),

              // Noise Intensity slider
              LockableSlider(
                label: 'Noise Intensity',
                value: widget.settings.vhsSettings.noiseIntensity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.vhsSettings.noiseIntensity * 100).round()}%',
                onChanged: (value) => _onNoiseIntensityChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.vhsNoiseIntensity,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                defaultValue: 0.7,
              ),

              const SizedBox(height: 16),

              // Field Lines slider
              LockableSlider(
                label: 'Field Lines',
                value: widget.settings.vhsSettings.fieldLines,
                min: 0.0,
                max: 400.0,
                divisions: 400,
                displayValue:
                    '${widget.settings.vhsSettings.fieldLines.round()}',
                onChanged: (value) => _onFieldLinesChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.vhsFieldLines,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                defaultValue: 240.0,
              ),

              const SizedBox(height: 16),

              // Horizontal Wave Strength slider
              LockableSlider(
                label: 'Wave Strength',
                value: widget.settings.vhsSettings.horizontalWaveStrength,
                min: 0.0,
                max: 0.5,
                divisions: 100,
                displayValue:
                    '${(widget.settings.vhsSettings.horizontalWaveStrength * 100).round()}%',
                onChanged: (value) => _onHorizontalWaveStrengthChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.vhsHorizontalWaveStrength,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                defaultValue: 0.15,
              ),

              const SizedBox(height: 16),

              // Horizontal Wave Screen Size slider
              LockableSlider(
                label: 'Wave Screen Size',
                value: widget.settings.vhsSettings.horizontalWaveScreenSize,
                min: 10.0,
                max: 200.0,
                divisions: 190,
                displayValue:
                    '${widget.settings.vhsSettings.horizontalWaveScreenSize.round()}',
                onChanged: (value) => _onHorizontalWaveScreenSizeChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.vhsHorizontalWaveScreenSize,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                defaultValue: 50.0,
              ),

              const SizedBox(height: 16),

              // Horizontal Wave Vertical Size slider
              LockableSlider(
                label: 'Wave Vertical Size',
                value: widget.settings.vhsSettings.horizontalWaveVerticalSize,
                min: 10.0,
                max: 300.0,
                divisions: 290,
                displayValue:
                    '${widget.settings.vhsSettings.horizontalWaveVerticalSize.round()}',
                onChanged: (value) =>
                    _onHorizontalWaveVerticalSizeChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.vhsHorizontalWaveVerticalSize,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                defaultValue: 100.0,
              ),

              const SizedBox(height: 16),

              // Dotted Noise Strength slider
              LockableSlider(
                label: 'Dotted Noise',
                value: widget.settings.vhsSettings.dottedNoiseStrength,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.vhsSettings.dottedNoiseStrength * 100).round()}%',
                onChanged: (value) => _onDottedNoiseStrengthChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.vhsDottedNoiseStrength,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                defaultValue: 0.2,
              ),

              const SizedBox(height: 16),

              // Horizontal Distortion Strength slider
              LockableSlider(
                label: 'Distortion Strength',
                value: widget.settings.vhsSettings.horizontalDistortionStrength,
                min: 0.0,
                max: 0.02,
                divisions: 100,
                displayValue:
                    '${(widget.settings.vhsSettings.horizontalDistortionStrength * 10000).round()}',
                onChanged: (value) =>
                    _onHorizontalDistortionStrengthChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.vhsHorizontalDistortionStrength,
                animationEnabled: widget.settings.vhsSettings.effectAnimated,
                defaultValue: 0.0087,
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

  // Handle slider changes
  void _onOpacityChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.vhsSettings.opacity = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onNoiseIntensityChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.vhsSettings.noiseIntensity = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onFieldLinesChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.vhsSettings.fieldLines = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onHorizontalWaveStrengthChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.vhsSettings.horizontalWaveStrength = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onHorizontalWaveScreenSizeChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.vhsSettings.horizontalWaveScreenSize = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onHorizontalWaveVerticalSizeChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.vhsSettings.horizontalWaveVerticalSize = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onDottedNoiseStrengthChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.vhsSettings.dottedNoiseStrength = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onHorizontalDistortionStrengthChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.vhsSettings.horizontalDistortionStrength = value;
    widget.onSettingsChanged(updatedSettings);
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
    updatedSettings.vhsSettings.opacity = presetData['opacity'] ?? 0.5;
    updatedSettings.vhsSettings.noiseIntensity =
        presetData['noiseIntensity'] ?? 0.7;
    updatedSettings.vhsSettings.fieldLines = presetData['fieldLines'] ?? 240.0;
    updatedSettings.vhsSettings.horizontalWaveStrength =
        presetData['horizontalWaveStrength'] ?? 0.15;
    updatedSettings.vhsSettings.horizontalWaveScreenSize =
        presetData['horizontalWaveScreenSize'] ?? 50.0;
    updatedSettings.vhsSettings.horizontalWaveVerticalSize =
        presetData['horizontalWaveVerticalSize'] ?? 100.0;
    updatedSettings.vhsSettings.dottedNoiseStrength =
        presetData['dottedNoiseStrength'] ?? 0.2;
    updatedSettings.vhsSettings.horizontalDistortionStrength =
        presetData['horizontalDistortionStrength'] ?? 0.0087;
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
      'noiseIntensity': widget.settings.vhsSettings.noiseIntensity,
      'fieldLines': widget.settings.vhsSettings.fieldLines,
      'horizontalWaveStrength':
          widget.settings.vhsSettings.horizontalWaveStrength,
      'horizontalWaveScreenSize':
          widget.settings.vhsSettings.horizontalWaveScreenSize,
      'horizontalWaveVerticalSize':
          widget.settings.vhsSettings.horizontalWaveVerticalSize,
      'dottedNoiseStrength': widget.settings.vhsSettings.dottedNoiseStrength,
      'horizontalDistortionStrength':
          widget.settings.vhsSettings.horizontalDistortionStrength,
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
