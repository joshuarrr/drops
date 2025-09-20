import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../controllers/animation_state_manager.dart';
import '../services/preset_refresh_service.dart';
import 'lockable_slider.dart';
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
              LockableSlider(
                label: 'Effect Opacity',
                value: widget.settings.glitchSettings.opacity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.glitchSettings.opacity * 100).round()}%',
                onChanged: (value) => _onOpacityChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.glitchOpacity,
                animationEnabled: widget.settings.glitchSettings.effectAnimated,
                defaultValue: 0.5,
              ),

              const SizedBox(height: 16),

              // Intensity slider
              LockableSlider(
                label: 'Intensity',
                value: widget.settings.glitchSettings.intensity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.glitchSettings.intensity * 100).round()}%',
                onChanged: (value) => _onIntensityChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.glitchIntensity,
                animationEnabled: widget.settings.glitchSettings.effectAnimated,
                defaultValue: 0.3,
              ),

              const SizedBox(height: 16),

              // Frequency slider
              LockableSlider(
                label: 'Frequency',
                value: widget.settings.glitchSettings.frequency,
                min: 0.0,
                max: 3.0,
                divisions: 100,
                displayValue:
                    '${widget.settings.glitchSettings.frequency.toStringAsFixed(1)}x',
                onChanged: (value) => _onFrequencyChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.glitchSpeed,
                animationEnabled: widget.settings.glitchSettings.effectAnimated,
                defaultValue: 1.0,
              ),

              const SizedBox(height: 16),

              // Block Size slider
              LockableSlider(
                label: 'Block Size',
                value: widget.settings.glitchSettings.blockSize,
                min: 0.0,
                max: 0.5,
                divisions: 100,
                displayValue:
                    '${(widget.settings.glitchSettings.blockSize * 100).round()}%',
                onChanged: (value) => _onBlockSizeChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.glitchBlockSize,
                animationEnabled: widget.settings.glitchSettings.effectAnimated,
                defaultValue: 0.1,
              ),

              const SizedBox(height: 16),

              // Horizontal Slice Intensity slider
              LockableSlider(
                label: 'Horizontal Slicing',
                value: widget.settings.glitchSettings.horizontalSliceIntensity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.glitchSettings.horizontalSliceIntensity * 100).round()}%',
                onChanged: (value) => _onHorizontalSliceIntensityChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.glitchHorizontalSliceIntensity,
                animationEnabled: widget.settings.glitchSettings.effectAnimated,
                defaultValue: 0.0,
              ),

              const SizedBox(height: 16),

              // Vertical Slice Intensity slider
              LockableSlider(
                label: 'Vertical Slicing',
                value: widget.settings.glitchSettings.verticalSliceIntensity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue:
                    '${(widget.settings.glitchSettings.verticalSliceIntensity * 100).round()}%',
                onChanged: (value) => _onVerticalSliceIntensityChanged(value),
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.glitchVerticalSliceIntensity,
                animationEnabled: widget.settings.glitchSettings.effectAnimated,
                defaultValue: 0.0,
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

  // Handle slider changes
  void _onOpacityChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.glitchSettings.opacity = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onIntensityChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.glitchSettings.intensity = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onFrequencyChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.glitchSettings.frequency = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onBlockSizeChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.glitchSettings.blockSize = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onHorizontalSliceIntensityChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.glitchSettings.horizontalSliceIntensity = value;
    widget.onSettingsChanged(updatedSettings);
  }

  void _onVerticalSliceIntensityChanged(double value) {
    final updatedSettings = widget.settings;
    updatedSettings.glitchSettings.verticalSliceIntensity = value;
    widget.onSettingsChanged(updatedSettings);
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
    updatedSettings.glitchSettings.opacity = presetData['opacity'] ?? 0.5;
    updatedSettings.glitchSettings.intensity = presetData['intensity'] ?? 0.3;
    updatedSettings.glitchSettings.frequency = presetData['frequency'] ?? 1.0;
    updatedSettings.glitchSettings.blockSize = presetData['blockSize'] ?? 0.1;
    updatedSettings.glitchSettings.horizontalSliceIntensity =
        presetData['horizontalSliceIntensity'] ?? 0.0;
    updatedSettings.glitchSettings.verticalSliceIntensity =
        presetData['verticalSliceIntensity'] ?? 0.0;
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
      'effectEnabled': true,
      'opacity': widget.settings.glitchSettings.opacity,
      'intensity': widget.settings.glitchSettings.intensity,
      'frequency': widget.settings.glitchSettings.frequency,
      'blockSize': widget.settings.glitchSettings.blockSize,
      'horizontalSliceIntensity':
          widget.settings.glitchSettings.horizontalSliceIntensity,
      'verticalSliceIntensity':
          widget.settings.glitchSettings.verticalSliceIntensity,
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
}
