import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/parameter_range.dart';
import '../models/presets_manager.dart';
import '../services/preset_refresh_service.dart';
import '../controllers/animation_state_manager.dart';
import 'range_lockable_slider.dart';
import 'animation_controls.dart';
import 'enhanced_panel_header.dart';
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
        EnhancedPanelHeader(
          aspect: ShaderAspect.rain,
          onPresetSelected: _applyPreset,
          onReset: _resetRain,
          onSavePreset: _savePresetForAspect,
          sliderColor: sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: settings.rainSettings.applyToImage,
          applyToText: settings.rainSettings.applyToText,
          onApplyToImageChanged: (value) {
            settings.rainSettings.applyToImage = value;
            onSettingsChanged(settings);
          },
          onApplyToTextChanged: (value) {
            settings.rainSettings.applyToText = value;
            onSettingsChanged(settings);
          },
        ),
        RangeLockableSlider(
          label: 'Rain Intensity',
          range: settings.rainSettings.rainIntensityRange,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          activeColor: sliderColor,
          formatValue: (v) => '${(v * 100).round()}%',
          defaults: ShaderSettings.defaults.rainSettings.rainIntensityRange,
          parameterId: ParameterIds.rainIntensity,
          animationEnabled: settings.rainSettings.rainAnimated,
          onRangeChanged: (range) {
            settings.rainSettings.setRainIntensityRange(range);
            if (!settings.rainEnabled) settings.rainEnabled = true;
            onSettingsChanged(settings);
          },
        ),
        RangeLockableSlider(
          label: 'Drop Size',
          range: settings.rainSettings.dropSizeRange,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          activeColor: sliderColor,
          formatValue: (v) => '${(v * 100).round()}%',
          defaults: ShaderSettings.defaults.rainSettings.dropSizeRange,
          parameterId: ParameterIds.rainDropSize,
          animationEnabled: settings.rainSettings.rainAnimated,
          onRangeChanged: (range) {
            settings.rainSettings.setDropSizeRange(range);
            if (!settings.rainEnabled) settings.rainEnabled = true;
            onSettingsChanged(settings);
          },
        ),
        RangeLockableSlider(
          label: 'Fall Speed',
          range: settings.rainSettings.fallSpeedRange,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          activeColor: sliderColor,
          formatValue: (v) => '${(v * 100).round()}%',
          defaults: ShaderSettings.defaults.rainSettings.fallSpeedRange,
          parameterId: ParameterIds.rainFallSpeed,
          animationEnabled: settings.rainSettings.rainAnimated,
          onRangeChanged: (range) {
            settings.rainSettings.setFallSpeedRange(range);
            if (!settings.rainEnabled) settings.rainEnabled = true;
            onSettingsChanged(settings);
          },
        ),
        RangeLockableSlider(
          label: 'Refraction',
          range: settings.rainSettings.refractionRange,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          activeColor: sliderColor,
          formatValue: (v) => '${(v * 100).round()}%',
          defaults: ShaderSettings.defaults.rainSettings.refractionRange,
          parameterId: ParameterIds.rainRefraction,
          animationEnabled: settings.rainSettings.rainAnimated,
          onRangeChanged: (range) {
            settings.rainSettings.setRefractionRange(range);
            if (!settings.rainEnabled) settings.rainEnabled = true;
            onSettingsChanged(settings);
          },
        ),
        RangeLockableSlider(
          label: 'Trail Intensity',
          range: settings.rainSettings.trailIntensityRange,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          activeColor: sliderColor,
          formatValue: (v) => '${(v * 100).round()}%',
          defaults: ShaderSettings.defaults.rainSettings.trailIntensityRange,
          parameterId: ParameterIds.rainTrailIntensity,
          animationEnabled: settings.rainSettings.rainAnimated,
          onRangeChanged: (range) {
            settings.rainSettings.setTrailIntensityRange(range);
            if (!settings.rainEnabled) settings.rainEnabled = true;
            onSettingsChanged(settings);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Animate', style: TextStyle(color: sliderColor, fontSize: 14)),
            Switch(
              value: settings.rainSettings.rainAnimated,
              thumbColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) ? sliderColor : null,
              ),
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

  void _resetRain() {
    final defaults = ShaderSettings.defaults;
    settings.rainEnabled = false;
    settings.rainSettings.rainIntensityRange.resetToDefaults(
      defaultMin: 0.0,
      defaultMax: 0.5,
    );
    settings.rainSettings.dropSizeRange.resetToDefaults(
      defaultMin: 0.0,
      defaultMax: 0.5,
    );
    settings.rainSettings.fallSpeedRange.resetToDefaults(
      defaultMin: 0.0,
      defaultMax: 0.5,
    );
    settings.rainSettings.refractionRange.resetToDefaults(
      defaultMin: 0.0,
      defaultMax: 0.5,
    );
    settings.rainSettings.trailIntensityRange.resetToDefaults(
      defaultMin: 0.0,
      defaultMax: 0.3,
    );
    settings.rainSettings.rainAnimated = defaults.rainSettings.rainAnimated;
    settings.rainSettings.rainAnimOptions = AnimationOptions();

    onSettingsChanged(settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    settings.rainEnabled = presetData['rainEnabled'] ?? settings.rainEnabled;

    // Apply range data if available, otherwise fall back to legacy values
    _applyRangeFromPreset(
      settings.rainSettings.rainIntensityRange,
      presetData,
      'rainIntensity',
      0.5,
    );
    _applyRangeFromPreset(
      settings.rainSettings.dropSizeRange,
      presetData,
      'dropSize',
      0.5,
    );
    _applyRangeFromPreset(
      settings.rainSettings.fallSpeedRange,
      presetData,
      'fallSpeed',
      0.5,
    );
    _applyRangeFromPreset(
      settings.rainSettings.refractionRange,
      presetData,
      'refraction',
      0.5,
    );
    _applyRangeFromPreset(
      settings.rainSettings.trailIntensityRange,
      presetData,
      'trailIntensity',
      0.3,
    );

    settings.rainSettings.rainAnimated =
        presetData['rainAnimated'] ?? settings.rainSettings.rainAnimated;

    if (presetData['rainAnimOptions'] != null) {
      settings.rainSettings.rainAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['rainAnimOptions']),
      );
    }

    onSettingsChanged(settings);
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

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'rainEnabled': settings.rainEnabled,
      'rainIntensity': settings.rainSettings.rainIntensity,
      'rainIntensityMin': settings.rainSettings.rainIntensityRange.userMin,
      'rainIntensityMax': settings.rainSettings.rainIntensityRange.userMax,
      'rainIntensityCurrent': settings.rainSettings.rainIntensityRange.current,
      'rainIntensityRange': settings.rainSettings.rainIntensityRange.toMap(),
      'dropSize': settings.rainSettings.dropSize,
      'dropSizeMin': settings.rainSettings.dropSizeRange.userMin,
      'dropSizeMax': settings.rainSettings.dropSizeRange.userMax,
      'dropSizeCurrent': settings.rainSettings.dropSizeRange.current,
      'dropSizeRange': settings.rainSettings.dropSizeRange.toMap(),
      'fallSpeed': settings.rainSettings.fallSpeed,
      'fallSpeedMin': settings.rainSettings.fallSpeedRange.userMin,
      'fallSpeedMax': settings.rainSettings.fallSpeedRange.userMax,
      'fallSpeedCurrent': settings.rainSettings.fallSpeedRange.current,
      'fallSpeedRange': settings.rainSettings.fallSpeedRange.toMap(),
      'refraction': settings.rainSettings.refraction,
      'refractionMin': settings.rainSettings.refractionRange.userMin,
      'refractionMax': settings.rainSettings.refractionRange.userMax,
      'refractionCurrent': settings.rainSettings.refractionRange.current,
      'refractionRange': settings.rainSettings.refractionRange.toMap(),
      'trailIntensity': settings.rainSettings.trailIntensity,
      'trailIntensityMin': settings.rainSettings.trailIntensityRange.userMin,
      'trailIntensityMax': settings.rainSettings.trailIntensityRange.userMax,
      'trailIntensityCurrent':
          settings.rainSettings.trailIntensityRange.current,
      'trailIntensityRange': settings.rainSettings.trailIntensityRange.toMap(),
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
    PresetRefreshService().refreshAspect(ShaderAspect.rain);
  }

  static Future<bool> _deletePresetAndUpdate(
    ShaderAspect aspect,
    String name,
  ) async {
    final success = await PresetsManager.deletePreset(aspect, name);
    if (success) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      // Trigger refresh after deletion
      PresetRefreshService().refreshAspect(aspect);
    }
    return success;
  }
}
