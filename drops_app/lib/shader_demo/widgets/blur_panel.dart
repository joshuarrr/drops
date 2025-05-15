import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import 'value_slider.dart';
import 'animation_controls.dart';
import 'aspect_panel_header.dart';
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
        AspectPanelHeader(
          aspect: ShaderAspect.blur,
          onPresetSelected: _applyPreset,
          onReset: _resetBlur,
          onSavePreset: _savePresetForAspect,
          sliderColor: sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
        ),
        ValueSlider(
          label: 'Shatter Amount',
          value: settings.blurAmount,
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.blurAmount = v),
          sliderColor: sliderColor,
          defaultValue: 0.0,
        ),
        ValueSlider(
          label: 'Shatter Radius',
          value:
              settings.blurRadius /
              120.0, // Scale down from max 120 to 0-1 range
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.blurRadius = v * 120.0),
          sliderColor: sliderColor,
          defaultValue: 15.0 / 120.0, // Default scaled value
        ),
        ValueSlider(
          label: 'Shatter Opacity',
          value: settings.blurOpacity,
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.blurOpacity = v),
          sliderColor: sliderColor,
          defaultValue: 1.0,
        ),
        ValueSlider(
          label: 'Intensity',
          value:
              (settings.blurIntensity - 1.0) /
              2.0, // Scale from 1-3 to 0-1 range
          onChanged: (value) => _onSliderChanged(
            value,
            (v) => settings.blurIntensity = 1.0 + v * 2.0,
          ),
          sliderColor: sliderColor,
          defaultValue: 0.0, // Default is 1.0 (middle position)
        ),
        ValueSlider(
          label: 'Contrast',
          value: settings.blurContrast / 2.0, // Scale from 0-2 to 0-1 range
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.blurContrast = v * 2.0),
          sliderColor: sliderColor,
          defaultValue: 0.0,
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
                selected: {settings.blurBlendMode},
                onSelectionChanged: (Set<int> selection) {
                  if (selection.isNotEmpty) {
                    settings.blurBlendMode = selection.first;
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
              value: settings.blurAnimated,
              activeThumbColor: sliderColor,
              onChanged: (value) {
                settings.blurAnimated = value;
                // Ensure effect is enabled when animation toggled on
                if (!settings.blurEnabled) settings.blurEnabled = true;
                onSettingsChanged(settings);
              },
            ),
          ],
        ),
        if (settings.blurAnimated)
          AnimationControls(
            animationSpeed: settings.blurAnimOptions.speed,
            onSpeedChanged: (v) {
              settings.blurAnimOptions = settings.blurAnimOptions.copyWith(
                speed: v,
              );
              onSettingsChanged(settings);
            },
            animationMode: settings.blurAnimOptions.mode,
            onModeChanged: (m) {
              settings.blurAnimOptions = settings.blurAnimOptions.copyWith(
                mode: m,
              );
              onSettingsChanged(settings);
            },
            animationEasing: settings.blurAnimOptions.easing,
            onEasingChanged: (e) {
              settings.blurAnimOptions = settings.blurAnimOptions.copyWith(
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
    if (!settings.blurEnabled) settings.blurEnabled = true;

    // Update the setting value
    setter(value);
    // Notify the parent widget
    onSettingsChanged(settings);
  }

  void _resetBlur() {
    final defaults = ShaderSettings();
    settings
      ..blurEnabled = false
      ..blurAmount = defaults.blurAmount
      ..blurRadius = defaults.blurRadius
      ..blurOpacity = defaults.blurOpacity
      ..blurBlendMode = defaults.blurBlendMode
      ..blurIntensity = defaults.blurIntensity
      ..blurContrast = defaults.blurContrast
      ..blurAnimated = false
      ..blurAnimOptions = AnimationOptions();

    onSettingsChanged(settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    settings.blurEnabled = presetData['blurEnabled'] ?? settings.blurEnabled;
    settings.blurAmount = presetData['blurAmount'] ?? settings.blurAmount;
    settings.blurRadius = presetData['blurRadius'] ?? settings.blurRadius;
    settings.blurOpacity = presetData['blurOpacity'] ?? settings.blurOpacity;
    settings.blurBlendMode =
        presetData['blurBlendMode'] ?? settings.blurBlendMode;
    settings.blurIntensity =
        presetData['blurIntensity'] ?? settings.blurIntensity;
    settings.blurContrast = presetData['blurContrast'] ?? settings.blurContrast;
    settings.blurAnimated = presetData['blurAnimated'] ?? settings.blurAnimated;

    if (presetData['blurAnimOptions'] != null) {
      settings.blurAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['blurAnimOptions']),
      );
    }

    onSettingsChanged(settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'blurEnabled': settings.blurEnabled,
      'blurAmount': settings.blurAmount,
      'blurRadius': settings.blurRadius,
      'blurOpacity': settings.blurOpacity,
      'blurBlendMode': settings.blurBlendMode,
      'blurIntensity': settings.blurIntensity,
      'blurContrast': settings.blurContrast,
      'blurAnimated': settings.blurAnimated,
      'blurAnimOptions': settings.blurAnimOptions.toMap(),
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
