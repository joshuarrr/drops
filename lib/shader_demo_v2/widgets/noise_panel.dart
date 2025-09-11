import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import 'lockable_slider.dart';
import 'animation_controls.dart';
import '../controllers/animation_state_manager.dart';
import 'enhanced_panel_header.dart';
import 'glass_panel.dart';

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
    return GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EnhancedPanelHeader(
            aspect: ShaderAspect.noise,
            onPresetSelected: _applyPreset,
            onReset: _resetNoise,
            onSavePreset: _savePresetForAspect,
            sliderColor: sliderColor,
            loadPresets: _loadPresetsForAspect,
            deletePreset: _deletePresetAndUpdate,
            refreshPresets: _refreshPresets,
            refreshCounter: _refreshCounter,
            applyToImage: settings.noiseSettings.applyToImage,
            applyToText: settings.noiseSettings.applyToText,
            onApplyToImageChanged: (value) {
              settings.noiseSettings.applyToImage = value;
              onSettingsChanged(settings);
            },
            onApplyToTextChanged: (value) {
              settings.noiseSettings.applyToText = value;
              onSettingsChanged(settings);
            },
          ),
          LockableSlider(
            label: 'Noise Scale',
            value: settings.noiseSettings.noiseScale,
            min: 0.1,
            max: 20.0,
            divisions: 199,
            displayValue: settings.noiseSettings.noiseScale.toStringAsFixed(1),
            onChanged: (value) => _onSliderChanged(
              value,
              (v) => settings.noiseSettings.noiseScale = v,
            ),
            activeColor: sliderColor,
            parameterId: ParameterIds.noiseScale,
            animationEnabled: settings.noiseSettings.noiseAnimated,
          ),
          // Only show noise speed slider when animation is enabled
          if (settings.noiseSettings.noiseAnimated)
            LockableSlider(
              label: 'Noise Speed',
              value: settings.noiseSettings.noiseSpeed,
              min: 0.0,
              max: 1.0,
              divisions: null,
              displayValue: settings.noiseSettings.noiseSpeed.toStringAsFixed(
                2,
              ),
              onChanged: (value) => _onSliderChanged(
                value,
                (v) => settings.noiseSettings.noiseSpeed = v,
              ),
              activeColor: sliderColor,
              parameterId: ParameterIds.noiseSpeed,
              animationEnabled: settings.noiseSettings.noiseAnimated,
              defaultValue: 0.5,
            ),
          LockableSlider(
            label: 'Wave Amount',
            value: settings.noiseSettings.waveAmount,
            min: 0.0,
            max: 0.1,
            divisions: null,
            displayValue: settings.noiseSettings.waveAmount.toStringAsFixed(3),
            onChanged: (value) => _onSliderChanged(
              value,
              (v) => settings.noiseSettings.waveAmount = v,
            ),
            activeColor: sliderColor,
            parameterId: ParameterIds.waveAmount,
            animationEnabled: settings.noiseSettings.noiseAnimated,
            defaultValue: 0.02,
          ),
          LockableSlider(
            label: 'Color Intensity',
            value: settings.noiseSettings.colorIntensity,
            min: 0.0,
            max: 1.0,
            divisions: null,
            displayValue: settings.noiseSettings.colorIntensity.toStringAsFixed(
              2,
            ),
            onChanged: (value) => _onSliderChanged(
              value,
              (v) => settings.noiseSettings.colorIntensity = v,
            ),
            activeColor: sliderColor,
            parameterId: ParameterIds.colorIntensity,
            animationEnabled: settings.noiseSettings.noiseAnimated,
            defaultValue: 0.3,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Animate',
                style: TextStyle(color: sliderColor, fontSize: 14),
              ),
              Switch(
                value: settings.noiseSettings.noiseAnimated,
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? sliderColor
                      : null,
                ),
                onChanged: (value) {
                  settings.noiseSettings.noiseAnimated = value;
                  if (!settings.noiseEnabled) settings.noiseEnabled = true;
                  onSettingsChanged(settings);
                },
              ),
            ],
          ),
          if (settings.noiseSettings.noiseAnimated)
            AnimationControls(
              animationSpeed: settings.noiseSettings.noiseAnimOptions.speed,
              onSpeedChanged: (v) {
                settings.noiseSettings.noiseAnimOptions = settings
                    .noiseSettings
                    .noiseAnimOptions
                    .copyWith(speed: v);
                onSettingsChanged(settings);
              },
              animationMode: settings.noiseSettings.noiseAnimOptions.mode,
              onModeChanged: (m) {
                settings.noiseSettings.noiseAnimOptions = settings
                    .noiseSettings
                    .noiseAnimOptions
                    .copyWith(mode: m);
                onSettingsChanged(settings);
              },
              animationEasing: settings.noiseSettings.noiseAnimOptions.easing,
              onEasingChanged: (e) {
                settings.noiseSettings.noiseAnimOptions = settings
                    .noiseSettings
                    .noiseAnimOptions
                    .copyWith(easing: e);
                onSettingsChanged(settings);
              },
              sliderColor: sliderColor,
            ),
        ],
      ),
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
    final defaults = ShaderSettings.defaults;
    settings.noiseEnabled = false;
    settings.noiseSettings.noiseScale = defaults.noiseSettings.noiseScale;
    settings.noiseSettings.noiseSpeed = defaults.noiseSettings.noiseSpeed;
    settings.noiseSettings.colorIntensity =
        defaults.noiseSettings.colorIntensity;
    settings.noiseSettings.waveAmount = defaults.noiseSettings.waveAmount;
    settings.noiseSettings.noiseAnimated = defaults.noiseSettings.noiseAnimated;
    settings.noiseSettings.noiseAnimOptions = AnimationOptions();

    onSettingsChanged(settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    settings.noiseEnabled = presetData['noiseEnabled'] ?? settings.noiseEnabled;
    settings.noiseSettings.noiseScale =
        presetData['noiseScale'] ?? settings.noiseSettings.noiseScale;
    settings.noiseSettings.noiseSpeed =
        presetData['noiseSpeed'] ?? settings.noiseSettings.noiseSpeed;
    settings.noiseSettings.colorIntensity =
        presetData['colorIntensity'] ?? settings.noiseSettings.colorIntensity;
    settings.noiseSettings.waveAmount =
        presetData['waveAmount'] ?? settings.noiseSettings.waveAmount;
    settings.noiseSettings.noiseAnimated =
        presetData['noiseAnimated'] ?? settings.noiseSettings.noiseAnimated;

    if (presetData['noiseAnimOptions'] != null) {
      settings.noiseSettings.noiseAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['noiseAnimOptions']),
      );
    }

    onSettingsChanged(settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'noiseEnabled': settings.noiseEnabled,
      'noiseScale': settings.noiseSettings.noiseScale,
      'noiseSpeed': settings.noiseSettings.noiseSpeed,
      'colorIntensity': settings.noiseSettings.colorIntensity,
      'waveAmount': settings.noiseSettings.waveAmount,
      'noiseAnimated': settings.noiseSettings.noiseAnimated,
      'noiseAnimOptions': settings.noiseSettings.noiseAnimOptions.toMap(),
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
    // TODO: Implement preset refresh in V2 architecture
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
