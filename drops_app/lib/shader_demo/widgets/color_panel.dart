import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import 'value_slider.dart';
import 'animation_controls.dart';
import 'aspect_panel_header.dart';

class ColorPanel extends StatelessWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const ColorPanel({
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
          aspect: ShaderAspect.color,
          onPresetSelected: _applyPreset,
          onReset: _resetColor,
          onSavePreset: _savePresetForAspect,
          sliderColor: sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
        ),
        ValueSlider(
          label: 'Hue',
          value: settings.hue,
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.hue = v),
          sliderColor: sliderColor,
          defaultValue: 0.0,
        ),
        ValueSlider(
          label: 'Saturation',
          value: settings.saturation,
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.saturation = v),
          sliderColor: sliderColor,
          defaultValue: 0.0,
        ),
        ValueSlider(
          label: 'Lightness',
          value: settings.lightness,
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.lightness = v),
          sliderColor: sliderColor,
          defaultValue: 0.0,
        ),
        const SizedBox(height: 16),
        // ----- Overlay group header -----
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            'Overlay',
            style: TextStyle(
              color: sliderColor.withOpacity(0.8),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ValueSlider(
          label: 'Overlay Hue',
          value: settings.overlayHue,
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.overlayHue = v),
          sliderColor: sliderColor,
          defaultValue: 0.0,
        ),
        ValueSlider(
          label: 'Overlay Intensity',
          value: settings.overlayIntensity,
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.overlayIntensity = v),
          sliderColor: sliderColor,
          defaultValue: 0.0,
        ),
        ValueSlider(
          label: 'Overlay Opacity',
          value: settings.overlayOpacity,
          onChanged: (value) =>
              _onSliderChanged(value, (v) => settings.overlayOpacity = v),
          sliderColor: sliderColor,
          defaultValue: 0.0,
        ),
        // Toggle animation for HSL adjustments
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Animate HSL',
              style: TextStyle(color: sliderColor, fontSize: 14),
            ),
            Switch(
              value: settings.colorAnimated,
              activeThumbColor: sliderColor,
              onChanged: (value) {
                settings.colorAnimated = value;
                if (!settings.colorEnabled) settings.colorEnabled = true;
                onSettingsChanged(settings);
              },
            ),
          ],
        ),
        if (settings.colorAnimated)
          AnimationControls(
            animationSpeed: settings.colorAnimOptions.speed,
            onSpeedChanged: (v) {
              settings.colorAnimOptions = settings.colorAnimOptions.copyWith(
                speed: v,
              );
              onSettingsChanged(settings);
            },
            animationMode: settings.colorAnimOptions.mode,
            onModeChanged: (m) {
              settings.colorAnimOptions = settings.colorAnimOptions.copyWith(
                mode: m,
              );
              onSettingsChanged(settings);
            },
            animationEasing: settings.colorAnimOptions.easing,
            onEasingChanged: (e) {
              settings.colorAnimOptions = settings.colorAnimOptions.copyWith(
                easing: e,
              );
              onSettingsChanged(settings);
            },
            sliderColor: sliderColor,
          ),

        // Toggle animation for overlay
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Animate Overlay',
              style: TextStyle(color: sliderColor, fontSize: 14),
            ),
            Switch(
              value: settings.overlayAnimated,
              activeThumbColor: sliderColor,
              onChanged: (value) {
                settings.overlayAnimated = value;
                if (!settings.colorEnabled) settings.colorEnabled = true;
                onSettingsChanged(settings);
              },
            ),
          ],
        ),
        if (settings.overlayAnimated)
          AnimationControls(
            animationSpeed: settings.overlayAnimOptions.speed,
            onSpeedChanged: (v) {
              settings.overlayAnimOptions = settings.overlayAnimOptions
                  .copyWith(speed: v);
              onSettingsChanged(settings);
            },
            animationMode: settings.overlayAnimOptions.mode,
            onModeChanged: (m) {
              settings.overlayAnimOptions = settings.overlayAnimOptions
                  .copyWith(mode: m);
              onSettingsChanged(settings);
            },
            animationEasing: settings.overlayAnimOptions.easing,
            onEasingChanged: (e) {
              settings.overlayAnimOptions = settings.overlayAnimOptions
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
    if (!settings.colorEnabled) settings.colorEnabled = true;

    // Update the setting value
    setter(value);
    // Notify the parent widget
    onSettingsChanged(settings);
  }

  void _resetColor() {
    final defaults = ShaderSettings();
    settings
      ..colorEnabled = false
      ..hue = defaults.hue
      ..saturation = defaults.saturation
      ..lightness = defaults.lightness
      ..overlayHue = defaults.overlayHue
      ..overlayIntensity = defaults.overlayIntensity
      ..overlayOpacity = defaults.overlayOpacity
      ..colorAnimated = false
      ..overlayAnimated = false
      ..colorAnimOptions = AnimationOptions()
      ..overlayAnimOptions = AnimationOptions();

    onSettingsChanged(settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    settings.colorEnabled = presetData['colorEnabled'] ?? settings.colorEnabled;
    settings.hue = presetData['hue'] ?? settings.hue;
    settings.saturation = presetData['saturation'] ?? settings.saturation;
    settings.lightness = presetData['lightness'] ?? settings.lightness;
    settings.overlayHue = presetData['overlayHue'] ?? settings.overlayHue;
    settings.overlayIntensity =
        presetData['overlayIntensity'] ?? settings.overlayIntensity;
    settings.overlayOpacity =
        presetData['overlayOpacity'] ?? settings.overlayOpacity;
    settings.colorAnimated =
        presetData['colorAnimated'] ?? settings.colorAnimated;
    settings.overlayAnimated =
        presetData['overlayAnimated'] ?? settings.overlayAnimated;

    if (presetData['colorAnimOptions'] != null) {
      settings.colorAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['colorAnimOptions']),
      );
    }

    if (presetData['overlayAnimOptions'] != null) {
      settings.overlayAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['overlayAnimOptions']),
      );
    }

    onSettingsChanged(settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'colorEnabled': settings.colorEnabled,
      'hue': settings.hue,
      'saturation': settings.saturation,
      'lightness': settings.lightness,
      'overlayHue': settings.overlayHue,
      'overlayIntensity': settings.overlayIntensity,
      'overlayOpacity': settings.overlayOpacity,
      'colorAnimated': settings.colorAnimated,
      'overlayAnimated': settings.overlayAnimated,
      'colorAnimOptions': settings.colorAnimOptions.toMap(),
      'overlayAnimOptions': settings.overlayAnimOptions.toMap(),
    };

    // These methods need to be implemented to work with the global preset system
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
    // This will need to be implemented to connect with the global preset system
    if (!_cachedPresets.containsKey(aspect)) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return _cachedPresets[aspect] ?? {};
  }

  static void _refreshPresets() {
    _refreshCounter++;
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
