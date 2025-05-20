import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import 'value_slider.dart';
import 'animation_controls.dart';
import 'enhanced_panel_header.dart';
import '../views/effect_controls.dart';

class BlurPanel extends StatelessWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const BlurPanel({
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
        EnhancedPanelHeader(
          aspect: ShaderAspect.blur,
          onPresetSelected: _applyPreset,
          onReset: _resetBlur,
          onSavePreset: _savePresetForAspect,
          sliderColor: sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: settings.blurSettings.applyToImage,
          applyToText: settings.blurSettings.applyToText,
          onApplyToImageChanged: (value) {
            settings.blurSettings.applyToImage = value;
            onSettingsChanged(settings);
          },
          onApplyToTextChanged: (value) {
            settings.blurSettings.applyToText = value;
            onSettingsChanged(settings);
          },
        ),
        ValueSlider(
          label: 'Shatter Amount',
          value: settings.blurSettings.blurAmount,
          onChanged: (value) => _onSliderChanged(
            value,
            (v) => settings.blurSettings.blurAmount = v,
          ),
          sliderColor: sliderColor,
          defaultValue: 0.0,
          debounceMillis: 150,
        ),
        ValueSlider(
          label: 'Shatter Radius',
          value:
              settings.blurSettings.blurRadius /
              120.0, // Scale down from max 120 to 0-1 range
          onChanged: (value) => _onSliderChanged(
            value,
            (v) => settings.blurSettings.blurRadius = v * 120.0,
          ),
          sliderColor: sliderColor,
          defaultValue: 15.0 / 120.0, // Default scaled value
          debounceMillis: 150,
        ),
        ValueSlider(
          label: 'Shatter Opacity',
          value: settings.blurSettings.blurOpacity,
          onChanged: (value) => _onSliderChanged(
            value,
            (v) => settings.blurSettings.blurOpacity = v,
          ),
          sliderColor: sliderColor,
          defaultValue: 1.0,
          debounceMillis: 150,
        ),
        ValueSlider(
          label: 'Intensity',
          value:
              (settings.blurSettings.blurIntensity - 1.0) /
              2.0, // Scale from 1-3 to 0-1 range
          onChanged: (value) => _onSliderChanged(
            value,
            (v) => settings.blurSettings.blurIntensity = 1.0 + v * 2.0,
          ),
          sliderColor: sliderColor,
          defaultValue: 0.0, // Default is 1.0 (middle position)
          debounceMillis: 150,
        ),
        ValueSlider(
          label: 'Contrast',
          value:
              settings.blurSettings.blurContrast /
              2.0, // Scale from 0-2 to 0-1 range
          onChanged: (value) => _onSliderChanged(
            value,
            (v) => settings.blurSettings.blurContrast = v * 2.0,
          ),
          sliderColor: sliderColor,
          defaultValue: 0.0,
          debounceMillis: 150,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Blend Mode',
                style: TextStyle(color: sliderColor, fontSize: 14),
              ),
              const SizedBox(height: 8),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment<int>(
                    value: 0,
                    label: Text('Normal', style: TextStyle(fontSize: 13)),
                  ),
                  ButtonSegment<int>(
                    value: 1,
                    label: Text('Multiply', style: TextStyle(fontSize: 13)),
                  ),
                  ButtonSegment<int>(
                    value: 2,
                    label: Text('Screen', style: TextStyle(fontSize: 13)),
                  ),
                ],
                selected: {settings.blurSettings.blurBlendMode},
                onSelectionChanged: (Set<int> selection) {
                  if (selection.isNotEmpty) {
                    settings.blurSettings.blurBlendMode = selection.first;
                    if (!settings.blurEnabled) settings.blurEnabled = true;
                    onSettingsChanged(settings);
                  }
                },
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Animate', style: TextStyle(color: sliderColor, fontSize: 14)),
            Switch(
              value: settings.blurSettings.blurAnimated,
              activeThumbColor: sliderColor,
              onChanged: (value) {
                settings.blurSettings.blurAnimated = value;
                // Ensure effect is enabled when animation toggled on
                if (!settings.blurEnabled) settings.blurEnabled = true;
                onSettingsChanged(settings);
              },
            ),
          ],
        ),
        if (settings.blurSettings.blurAnimated)
          AnimationControls(
            animationSpeed: settings.blurSettings.blurAnimOptions.speed,
            onSpeedChanged: (v) {
              settings.blurSettings.blurAnimOptions = settings
                  .blurSettings
                  .blurAnimOptions
                  .copyWith(speed: v);
              onSettingsChanged(settings);
            },
            animationMode: settings.blurSettings.blurAnimOptions.mode,
            onModeChanged: (m) {
              settings.blurSettings.blurAnimOptions = settings
                  .blurSettings
                  .blurAnimOptions
                  .copyWith(mode: m);
              onSettingsChanged(settings);
            },
            animationEasing: settings.blurSettings.blurAnimOptions.easing,
            onEasingChanged: (e) {
              settings.blurSettings.blurAnimOptions = settings
                  .blurSettings
                  .blurAnimOptions
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
    if (!settings.blurEnabled) settings.blurEnabled = true;

    // Update the setting value
    setter(value);
    // Notify the parent widget
    onSettingsChanged(settings);
  }

  void _resetBlur() {
    final defaults = ShaderSettings();
    settings.blurEnabled = false;
    settings.blurSettings.blurAmount = defaults.blurSettings.blurAmount;
    settings.blurSettings.blurRadius = defaults.blurSettings.blurRadius;
    settings.blurSettings.blurOpacity = defaults.blurSettings.blurOpacity;
    settings.blurSettings.blurBlendMode = defaults.blurSettings.blurBlendMode;
    settings.blurSettings.blurIntensity = defaults.blurSettings.blurIntensity;
    settings.blurSettings.blurContrast = defaults.blurSettings.blurContrast;
    settings.blurSettings.blurAnimated = false;
    settings.blurSettings.blurAnimOptions = AnimationOptions();

    onSettingsChanged(settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    settings.blurEnabled = presetData['blurEnabled'] ?? settings.blurEnabled;
    settings.blurSettings.blurAmount =
        presetData['blurAmount'] ?? settings.blurSettings.blurAmount;
    settings.blurSettings.blurRadius =
        presetData['blurRadius'] ?? settings.blurSettings.blurRadius;
    settings.blurSettings.blurOpacity =
        presetData['blurOpacity'] ?? settings.blurSettings.blurOpacity;
    settings.blurSettings.blurBlendMode =
        presetData['blurBlendMode'] ?? settings.blurSettings.blurBlendMode;
    settings.blurSettings.blurIntensity =
        presetData['blurIntensity'] ?? settings.blurSettings.blurIntensity;
    settings.blurSettings.blurContrast =
        presetData['blurContrast'] ?? settings.blurSettings.blurContrast;
    settings.blurSettings.blurAnimated =
        presetData['blurAnimated'] ?? settings.blurSettings.blurAnimated;

    if (presetData['blurAnimOptions'] != null) {
      settings.blurSettings.blurAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['blurAnimOptions']),
      );
    }

    onSettingsChanged(settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'blurEnabled': settings.blurEnabled,
      'blurAmount': settings.blurSettings.blurAmount,
      'blurRadius': settings.blurSettings.blurRadius,
      'blurOpacity': settings.blurSettings.blurOpacity,
      'blurBlendMode': settings.blurSettings.blurBlendMode,
      'blurIntensity': settings.blurSettings.blurIntensity,
      'blurContrast': settings.blurSettings.blurContrast,
      'blurAnimated': settings.blurSettings.blurAnimated,
      'blurAnimOptions': settings.blurSettings.blurAnimOptions.toMap(),
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
