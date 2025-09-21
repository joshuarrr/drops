import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import '../services/preset_refresh_service.dart';
import '../models/parameter_range.dart';
import 'range_lockable_slider.dart';
import 'animation_controls.dart';
import '../controllers/animation_state_manager.dart';
import 'enhanced_panel_header.dart';

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
    final noiseSettings = settings.noiseSettings;
    final noiseDefaults = ShaderSettings.defaults.noiseSettings;

    return Column(
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
        RangeLockableSlider(
          label: 'Noise Scale',
          range: noiseSettings.noiseScaleRange,
          min: 0.1,
          max: 20.0,
          divisions: 199,
          activeColor: sliderColor,
          formatValue: (v) => v.toStringAsFixed(1),
          defaults: noiseDefaults.noiseScaleRange,
          parameterId: ParameterIds.noiseScale,
          animationEnabled: noiseSettings.noiseAnimated,
          onRangeChanged: (range) => _onRangeChanged(
            range,
            (updated) => noiseSettings.setNoiseScaleRange(updated),
          ),
        ),
        // Only show noise speed slider when animation is enabled
        if (settings.noiseSettings.noiseAnimated)
          RangeLockableSlider(
            label: 'Noise Speed',
            range: noiseSettings.noiseSpeedRange,
            min: 0.0,
            max: 1.0,
            divisions: null,
            activeColor: sliderColor,
            formatValue: (v) => v.toStringAsFixed(2),
            defaults: noiseDefaults.noiseSpeedRange,
            parameterId: ParameterIds.noiseSpeed,
            animationEnabled: noiseSettings.noiseAnimated,
            onRangeChanged: (range) => _onRangeChanged(
              range,
              (updated) => noiseSettings.setNoiseSpeedRange(updated),
            ),
          ),
        RangeLockableSlider(
          label: 'Wave Amount',
          range: noiseSettings.waveAmountRange,
          min: 0.0,
          max: 0.1,
          divisions: 100,
          activeColor: sliderColor,
          formatValue: (v) => v.toStringAsFixed(3),
          defaults: noiseDefaults.waveAmountRange,
          parameterId: ParameterIds.waveAmount,
          animationEnabled: noiseSettings.noiseAnimated,
          onRangeChanged: (range) => _onRangeChanged(
            range,
            (updated) => noiseSettings.setWaveAmountRange(updated),
          ),
        ),
        RangeLockableSlider(
          label: 'Color Intensity',
          range: noiseSettings.colorIntensityRange,
          min: 0.0,
          max: 1.0,
          divisions: 100,
          activeColor: sliderColor,
          formatValue: (v) => v.toStringAsFixed(2),
          defaults: noiseDefaults.colorIntensityRange,
          parameterId: ParameterIds.colorIntensity,
          animationEnabled: noiseSettings.noiseAnimated,
          onRangeChanged: (range) => _onRangeChanged(
            range,
            (updated) => noiseSettings.setColorIntensityRange(updated),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Animate', style: TextStyle(color: sliderColor, fontSize: 14)),
            Switch(
              value: settings.noiseSettings.noiseAnimated,
              thumbColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) ? sliderColor : null,
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
    );
  }

  void _onRangeChanged(
    ParameterRange range,
    void Function(ParameterRange) apply,
  ) {
    if (!settings.noiseEnabled) settings.noiseEnabled = true;
    apply(range);
    onSettingsChanged(settings);
  }

  void _resetNoise() {
    final defaults = ShaderSettings.defaults;
    settings.noiseEnabled = false;
    settings.noiseSettings.setNoiseScaleRange(
      defaults.noiseSettings.noiseScaleRange,
    );
    settings.noiseSettings.setNoiseSpeedRange(
      defaults.noiseSettings.noiseSpeedRange,
    );
    settings.noiseSettings.setColorIntensityRange(
      defaults.noiseSettings.colorIntensityRange,
    );
    settings.noiseSettings.setWaveAmountRange(
      defaults.noiseSettings.waveAmountRange,
    );
    settings.noiseSettings.noiseAnimated = defaults.noiseSettings.noiseAnimated;
    settings.noiseSettings.noiseAnimOptions = AnimationOptions();

    onSettingsChanged(settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    settings.noiseEnabled = presetData['noiseEnabled'] ?? settings.noiseEnabled;
    settings.noiseSettings.setNoiseScaleRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'noiseScaleRange',
        valueKey: 'noiseScale',
        minKey: 'noiseScaleMin',
        maxKey: 'noiseScaleMax',
        currentKey: 'noiseScaleCurrent',
        hardMin: 0.1,
        hardMax: 20.0,
        fallbackValue: settings.noiseSettings.noiseScale,
      ),
    );
    settings.noiseSettings.setNoiseSpeedRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'noiseSpeedRange',
        valueKey: 'noiseSpeed',
        minKey: 'noiseSpeedMin',
        maxKey: 'noiseSpeedMax',
        currentKey: 'noiseSpeedCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: settings.noiseSettings.noiseSpeed,
      ),
    );
    settings.noiseSettings.setColorIntensityRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'colorIntensityRange',
        valueKey: 'colorIntensity',
        minKey: 'colorIntensityMin',
        maxKey: 'colorIntensityMax',
        currentKey: 'colorIntensityCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: settings.noiseSettings.colorIntensity,
      ),
    );
    settings.noiseSettings.setWaveAmountRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'waveAmountRange',
        valueKey: 'waveAmount',
        minKey: 'waveAmountMin',
        maxKey: 'waveAmountMax',
        currentKey: 'waveAmountCurrent',
        hardMin: 0.0,
        hardMax: 0.1,
        fallbackValue: settings.noiseSettings.waveAmount,
      ),
    );
    settings.noiseSettings.noiseAnimated =
        presetData['noiseAnimated'] ?? settings.noiseSettings.noiseAnimated;

    if (presetData['noiseAnimOptions'] != null) {
      settings.noiseSettings.noiseAnimOptions = AnimationOptions.fromMap(
        Map<String, dynamic>.from(presetData['noiseAnimOptions']),
      );
    }

    onSettingsChanged(settings);
  }

  ParameterRange _rangeFromPreset(
    Map<String, dynamic> presetData, {
    required String rangeKey,
    required String valueKey,
    required String minKey,
    required String maxKey,
    required String currentKey,
    required double hardMin,
    required double hardMax,
    required double fallbackValue,
  }) {
    final double fallback = _readDouble(
      presetData[valueKey],
      fallbackValue,
    ).clamp(hardMin, hardMax)
        .toDouble();

    final dynamic payload = presetData[rangeKey];
    if (payload is Map<String, dynamic>) {
      return ParameterRange.fromMap(
        Map<String, dynamic>.from(payload),
        hardMin: hardMin,
        hardMax: hardMax,
        fallbackValue: fallback,
      );
    }

    final double userMin = _readDouble(
      presetData[minKey],
      hardMin,
    ).clamp(hardMin, hardMax)
        .toDouble();
    final double userMax = _readDouble(
      presetData[maxKey],
      fallback,
    ).clamp(hardMin, hardMax)
        .toDouble();
    final double current = _readDouble(
      presetData[currentKey],
      fallback,
    ).clamp(hardMin, hardMax)
        .toDouble();

    return ParameterRange(
      hardMin: hardMin,
      hardMax: hardMax,
      initialValue: current,
      userMin: userMin,
      userMax: userMax,
    );
  }

  double _readDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    return fallback;
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'noiseEnabled': settings.noiseEnabled,
      'noiseScale': settings.noiseSettings.noiseScale,
      'noiseScaleMin': settings.noiseSettings.noiseScaleRange.userMin,
      'noiseScaleMax': settings.noiseSettings.noiseScaleRange.userMax,
      'noiseScaleCurrent': settings.noiseSettings.noiseScaleRange.current,
      'noiseScaleRange': settings.noiseSettings.noiseScaleRange.toMap(),
      'noiseSpeed': settings.noiseSettings.noiseSpeed,
      'noiseSpeedMin': settings.noiseSettings.noiseSpeedRange.userMin,
      'noiseSpeedMax': settings.noiseSettings.noiseSpeedRange.userMax,
      'noiseSpeedCurrent': settings.noiseSettings.noiseSpeedRange.current,
      'noiseSpeedRange': settings.noiseSettings.noiseSpeedRange.toMap(),
      'colorIntensity': settings.noiseSettings.colorIntensity,
      'colorIntensityMin': settings.noiseSettings.colorIntensityRange.userMin,
      'colorIntensityMax': settings.noiseSettings.colorIntensityRange.userMax,
      'colorIntensityCurrent': settings.noiseSettings.colorIntensityRange.current,
      'colorIntensityRange': settings.noiseSettings.colorIntensityRange.toMap(),
      'waveAmount': settings.noiseSettings.waveAmount,
      'waveAmountMin': settings.noiseSettings.waveAmountRange.userMin,
      'waveAmountMax': settings.noiseSettings.waveAmountRange.userMax,
      'waveAmountCurrent': settings.noiseSettings.waveAmountRange.current,
      'waveAmountRange': settings.noiseSettings.waveAmountRange.toMap(),
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
    PresetRefreshService().refreshAspect(ShaderAspect.noise);
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
