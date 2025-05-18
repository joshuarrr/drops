import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import 'value_slider.dart';
import 'animation_controls.dart';
import 'aspect_panel_header.dart';
import '../views/effect_controls.dart';

class RainPanel extends StatelessWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const RainPanel({
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
          aspect: ShaderAspect.rain,
          onPresetSelected: _applyPreset,
          onReset: _resetRain,
          onSavePreset: _savePresetForAspect,
          sliderColor: sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
        ),
        ValueSlider(
          label: 'Rain Intensity',
          value: settings.rainSettings.rainIntensity,
          onChanged: (value) => _onSliderChanged(
            value,
            (v) => settings.rainSettings.rainIntensity = v,
          ),
          sliderColor: sliderColor,
          defaultValue: 0.5,
        ),
        ValueSlider(
          label: 'Drop Size',
          value: settings.rainSettings.dropSize,
          onChanged: (value) => _onSliderChanged(
            value,
            (v) => settings.rainSettings.dropSize = v,
          ),
          sliderColor: sliderColor,
          defaultValue: 0.5,
        ),
        ValueSlider(
          label: 'Fall Speed',
          value: settings.rainSettings.fallSpeed,
          onChanged: (value) => _onSliderChanged(
            value,
            (v) => settings.rainSettings.fallSpeed = v,
          ),
          sliderColor: sliderColor,
          defaultValue: 0.5,
        ),
        ValueSlider(
          label: 'Refraction',
          value: settings.rainSettings.refraction,
          onChanged: (value) => _onSliderChanged(
            value,
            (v) => settings.rainSettings.refraction = v,
          ),
          sliderColor: sliderColor,
          defaultValue: 0.5,
        ),
        ValueSlider(
          label: 'Trail Intensity',
          value: settings.rainSettings.trailIntensity,
          onChanged: (value) => _onSliderChanged(
            value,
            (v) => settings.rainSettings.trailIntensity = v,
          ),
          sliderColor: sliderColor,
          defaultValue: 0.3,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Animate', style: TextStyle(color: sliderColor, fontSize: 14)),
            Switch(
              value: settings.rainSettings.rainAnimated,
              activeThumbColor: sliderColor,
              onChanged: (value) {
                settings.rainSettings.rainAnimated = value;
                if (!settings.rainEnabled) settings.rainEnabled = true;
                onSettingsChanged(settings);
              },
            ),
          ],
        ),
        if (settings.rainSettings.rainAnimated)
          AnimationControls(
            animationSpeed: settings.rainSettings.rainAnimOptions.speed,
            onSpeedChanged: (v) {
              settings.rainSettings.rainAnimOptions = settings
                  .rainSettings
                  .rainAnimOptions
                  .copyWith(speed: v);
              onSettingsChanged(settings);
            },
            animationMode: settings.rainSettings.rainAnimOptions.mode,
            onModeChanged: (m) {
              settings.rainSettings.rainAnimOptions = settings
                  .rainSettings
                  .rainAnimOptions
                  .copyWith(mode: m);
              onSettingsChanged(settings);
            },
            animationEasing: settings.rainSettings.rainAnimOptions.easing,
            onEasingChanged: (e) {
              settings.rainSettings.rainAnimOptions = settings
                  .rainSettings
                  .rainAnimOptions
                  .copyWith(easing: e);
              onSettingsChanged(settings);
            },
            sliderColor: sliderColor,
          ),
      ],
    );
  }

  void _onSliderChanged(double value, Function(double) setter) {
    // Enable the corresponding effect if it's not already enabled
    if (!settings.rainEnabled) settings.rainEnabled = true;

    // Update the setting value
    setter(value);
    // Notify the parent widget
    onSettingsChanged(settings);
  }

  void _resetRain() {
    final defaults = ShaderSettings();
    settings.rainEnabled = false;
    settings.rainSettings.rainIntensity = defaults.rainSettings.rainIntensity;
    settings.rainSettings.dropSize = defaults.rainSettings.dropSize;
    settings.rainSettings.fallSpeed = defaults.rainSettings.fallSpeed;
    settings.rainSettings.refraction = defaults.rainSettings.refraction;
    settings.rainSettings.trailIntensity = defaults.rainSettings.trailIntensity;
    settings.rainSettings.rainAnimated = defaults.rainSettings.rainAnimated;
    settings.rainSettings.rainAnimOptions = AnimationOptions();

    onSettingsChanged(settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    settings.rainEnabled = presetData['rainEnabled'] ?? settings.rainEnabled;
    settings.rainSettings.rainIntensity =
        presetData['rainIntensity'] ?? settings.rainSettings.rainIntensity;
    settings.rainSettings.dropSize =
        presetData['dropSize'] ?? settings.rainSettings.dropSize;
    settings.rainSettings.fallSpeed =
        presetData['fallSpeed'] ?? settings.rainSettings.fallSpeed;
    settings.rainSettings.refraction =
        presetData['refraction'] ?? settings.rainSettings.refraction;
    settings.rainSettings.trailIntensity =
        presetData['trailIntensity'] ?? settings.rainSettings.trailIntensity;
    settings.rainSettings.rainAnimated =
        presetData['rainAnimated'] ?? settings.rainSettings.rainAnimated;

    if (presetData['rainAnimOptions'] != null) {
      settings.rainSettings.rainAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['rainAnimOptions']),
      );
    }

    onSettingsChanged(settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'rainEnabled': settings.rainEnabled,
      'rainIntensity': settings.rainSettings.rainIntensity,
      'dropSize': settings.rainSettings.dropSize,
      'fallSpeed': settings.rainSettings.fallSpeed,
      'refraction': settings.rainSettings.refraction,
      'trailIntensity': settings.rainSettings.trailIntensity,
      'rainAnimated': settings.rainSettings.rainAnimated,
      'rainAnimOptions': settings.rainSettings.rainAnimOptions.toMap(),
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
