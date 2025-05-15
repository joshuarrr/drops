import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import 'value_slider.dart';
import 'animation_controls.dart';
import 'aspect_panel_header.dart';
import '../views/effect_controls.dart';

class NoisePanel extends StatelessWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const NoisePanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AspectPanelHeader(
          aspect: ShaderAspect.noise,
          onPresetSelected: _applyPreset,
          onReset: _resetNoise,
          onSavePreset: _savePresetForAspect,
          sliderColor: sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
        ),
        ValueSlider(
          label: 'Noise Scale',
          value: settings.noiseScale / 10.0, // Scale to 0-1 range (max 10)
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.noiseScale = v * 10.0),
          sliderColor: sliderColor,
          defaultValue: 0.5,
        ),
        ValueSlider(
          label: 'Noise Speed',
          value: settings.noiseSpeed, // Already in 0-1 range
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.noiseSpeed = v),
          sliderColor: sliderColor,
          defaultValue: 0.5,
        ),
        ValueSlider(
          label: 'Wave Amount',
          value: settings.waveAmount / 0.1, // Scale to 0-1 range (max 0.1)
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.waveAmount = v * 0.1),
          sliderColor: sliderColor,
          defaultValue: 0.2,
        ),
        ValueSlider(
          label: 'Color Intensity',
          value: settings.colorIntensity,
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.colorIntensity = v),
          sliderColor: sliderColor,
          defaultValue: 0.3,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Animate', style: TextStyle(color: sliderColor, fontSize: 14)),
            Switch(
              value: settings.noiseAnimated,
              activeThumbColor: sliderColor,
              onChanged: (value) {
                settings.noiseAnimated = value;
                if (!settings.noiseEnabled) settings.noiseEnabled = true;
                onSettingsChanged(settings);
              },
            ),
          ],
        ),
        if (settings.noiseAnimated)
          AnimationControls(
            animationSpeed: settings.noiseAnimOptions.speed,
            onSpeedChanged: (v) {
              settings.noiseAnimOptions = settings.noiseAnimOptions.copyWith(
                speed: v,
              );
              onSettingsChanged(settings);
            },
            animationMode: settings.noiseAnimOptions.mode,
            onModeChanged: (m) {
              settings.noiseAnimOptions = settings.noiseAnimOptions.copyWith(
                mode: m,
              );
              onSettingsChanged(settings);
            },
            animationEasing: settings.noiseAnimOptions.easing,
            onEasingChanged: (e) {
              settings.noiseAnimOptions = settings.noiseAnimOptions.copyWith(
                easing: e,
              );
              onSettingsChanged(settings);
            },
            sliderColor: sliderColor,
          ),
      ],
    );
  }

  void _onSliderChanged(double value, Function(double) setter) {
    // Enable the corresponding effect if it's not already enabled
    if (!settings.noiseEnabled) settings.noiseEnabled = true;

    // Update the setting value
    setter(value);
    // Notify the parent widget
    onSettingsChanged(settings);
  }

  void _resetNoise() {
    final defaults = ShaderSettings();
    settings
      ..noiseEnabled = false
      ..noiseScale = defaults.noiseScale
      ..noiseSpeed = defaults.noiseSpeed
      ..colorIntensity = defaults.colorIntensity
      ..waveAmount = defaults.waveAmount
      ..noiseAnimated = false
      ..noiseAnimOptions = AnimationOptions();

    onSettingsChanged(settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    settings.noiseEnabled = presetData['noiseEnabled'] ?? settings.noiseEnabled;
    settings.noiseScale = presetData['noiseScale'] ?? settings.noiseScale;
    settings.noiseSpeed = presetData['noiseSpeed'] ?? settings.noiseSpeed;
    settings.colorIntensity =
        presetData['colorIntensity'] ?? settings.colorIntensity;
    settings.waveAmount = presetData['waveAmount'] ?? settings.waveAmount;
    settings.noiseAnimated =
        presetData['noiseAnimated'] ?? settings.noiseAnimated;

    if (presetData['noiseAnimOptions'] != null) {
      settings.noiseAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['noiseAnimOptions']),
      );
    }

    onSettingsChanged(settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'noiseEnabled': settings.noiseEnabled,
      'noiseScale': settings.noiseScale,
      'noiseSpeed': settings.noiseSpeed,
      'colorIntensity': settings.colorIntensity,
      'waveAmount': settings.waveAmount,
      'noiseAnimated': settings.noiseAnimated,
      'noiseAnimOptions': settings.noiseAnimOptions.toMap(),
    };

    bool success = await PresetsManager.savePreset(aspect, name, presetData);

    if (success) {
      // Update cached presets
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      // Force refresh of the UI to show the new preset immediately
      _refreshPresets();
    }
  }

  // These will need to be connected to EffectControls static methods
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  static Future<Map<String, dynamic>> _loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    // Delegate to EffectControls
    if (!_cachedPresets.containsKey(aspect)) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return _cachedPresets[aspect] ?? {};
  }

  static void _refreshPresets() {
    _refreshCounter++;
    // Call the central refresh method for immediate UI update
    EffectControls.refreshPresets();
  }

  static Future<bool> _deletePresetAndUpdate(
    ShaderAspect aspect,
    String name,
  ) async {
    final success = await PresetsManager.deletePreset(aspect, name);
    if (success) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return success;
  }
}
