import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../controllers/effect_controls_bridge.dart';
import '../models/animation_options.dart';
import '../models/blur_settings.dart';
import '../models/presets_manager.dart';
import '../services/preset_refresh_service.dart';
import '../controllers/animation_state_manager.dart';
import '../models/parameter_range.dart';
import 'range_lockable_slider.dart';
import 'animation_controls.dart';
import 'enhanced_panel_header.dart';

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

  /// Helper method to create deep copy and call onSettingsChanged
  void _updateSettings(void Function(ShaderSettings) updateFn) {
    final updatedSettings = ShaderSettings.fromMap(settings.toMap());
    updateFn(updatedSettings);
    onSettingsChanged(updatedSettings);
  }

  @override
  Widget build(BuildContext context) {
    final blurSettings = settings.blurSettings;
    final blurDefaults = ShaderSettings.defaults.blurSettings;

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
            _updateSettings((s) => s.blurSettings.applyToImage = value);
          },
          onApplyToTextChanged: (value) {
            _updateSettings((s) => s.blurSettings.applyToText = value);
          },
        ),
        ..._buildRangeSliders(blurSettings, blurDefaults),
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
                    _updateSettings((s) {
                      s.blurSettings.blurBlendMode = selection.first;
                      if (!s.blurEnabled) s.blurEnabled = true;
                    });
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
              thumbColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.selected) ? sliderColor : null,
              ),
              onChanged: (value) {
                _updateSettings((s) {
                  s.blurSettings.blurAnimated = value;
                  // Ensure effect is enabled when animation toggled on
                  if (!s.blurEnabled) s.blurEnabled = true;
                });
              },
            ),
          ],
        ),
        if (settings.blurSettings.blurAnimated)
          AnimationControls(
            animationSpeed: settings.blurSettings.blurAnimOptions.speed,
            onSpeedChanged: (v) {
              _updateSettings((s) {
                s.blurSettings.blurAnimOptions = s.blurSettings.blurAnimOptions
                    .copyWith(speed: v);
              });
            },
            animationMode: settings.blurSettings.blurAnimOptions.mode,
            onModeChanged: (m) {
              _updateSettings((s) {
                s.blurSettings.blurAnimOptions = s.blurSettings.blurAnimOptions
                    .copyWith(mode: m);
              });
            },
            animationEasing: settings.blurSettings.blurAnimOptions.easing,
            onEasingChanged: (e) {
              _updateSettings((s) {
                s.blurSettings.blurAnimOptions = s.blurSettings.blurAnimOptions
                    .copyWith(easing: e);
              });
            },
            sliderColor: sliderColor,
          ),
      ],
    );
  }

  List<Widget> _buildRangeSliders(
    BlurSettings blurSettings,
    BlurSettings blurDefaults,
  ) {
    String formatPercent(double value) => '${(value * 100).round()}%';
    String formatPixels(double value) => '${value.round()}px';
    String formatMultiplier(double value) => '${value.toStringAsFixed(1)}x';

    return [
      RangeLockableSlider(
        label: 'Shatter Amount',
        range: blurSettings.blurAmountRange,
        min: 0.0,
        max: 1.0,
        divisions: 100,
        activeColor: sliderColor,
        formatValue: formatPercent,
        defaults: blurDefaults.blurAmountRange,
        parameterId: ParameterIds.blurAmount,
        animationEnabled: blurSettings.blurAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (s, updated) => s.blurSettings.setBlurAmountRange(updated),
        ),
      ),
      RangeLockableSlider(
        label: 'Shatter Radius',
        range: blurSettings.blurRadiusRange,
        min: 0.0,
        max: 120.0,
        divisions: 120,
        activeColor: sliderColor,
        formatValue: formatPixels,
        defaults: blurDefaults.blurRadiusRange,
        parameterId: ParameterIds.blurRadius,
        animationEnabled: blurSettings.blurAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (s, updated) => s.blurSettings.setBlurRadiusRange(updated),
        ),
      ),
      RangeLockableSlider(
        label: 'Shatter Opacity',
        range: blurSettings.blurOpacityRange,
        min: 0.0,
        max: 1.0,
        divisions: 100,
        activeColor: sliderColor,
        formatValue: formatPercent,
        defaults: blurDefaults.blurOpacityRange,
        parameterId: ParameterIds.blurOpacity,
        animationEnabled: blurSettings.blurAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (s, updated) => s.blurSettings.setBlurOpacityRange(updated),
        ),
      ),
      RangeLockableSlider(
        label: 'Intensity',
        range: blurSettings.blurIntensityRange,
        min: 0.0,
        max: 3.0,
        divisions: null,
        activeColor: sliderColor,
        formatValue: formatMultiplier,
        defaults: blurDefaults.blurIntensityRange,
        parameterId: ParameterIds.blurIntensity,
        animationEnabled: blurSettings.blurAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (s, updated) => s.blurSettings.setBlurIntensityRange(updated),
        ),
      ),
      RangeLockableSlider(
        label: 'Contrast',
        range: blurSettings.blurContrastRange,
        min: 0.0,
        max: 2.0,
        divisions: null,
        activeColor: sliderColor,
        formatValue: formatPercent,
        defaults: blurDefaults.blurContrastRange,
        parameterId: ParameterIds.blurContrast,
        animationEnabled: blurSettings.blurAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (s, updated) => s.blurSettings.setBlurContrastRange(updated),
        ),
      ),
    ];
  }

  void _onRangeChanged(
    ParameterRange range,
    void Function(ShaderSettings, ParameterRange) setter,
  ) {
    _updateSettings((s) {
      if (!s.blurEnabled) s.blurEnabled = true;
      setter(s, range);
    });
  }

  void _resetBlur() {
    final defaults = ShaderSettings.defaults;
    _updateSettings((s) {
      s.blurEnabled = false;
      s.blurSettings.setBlurAmountRange(
        defaults.blurSettings.blurAmountRange,
      );
      s.blurSettings.setBlurRadiusRange(
        defaults.blurSettings.blurRadiusRange,
      );
      s.blurSettings.setBlurOpacityRange(
        defaults.blurSettings.blurOpacityRange,
      );
      s.blurSettings.blurBlendMode = defaults.blurSettings.blurBlendMode;
      s.blurSettings.setBlurIntensityRange(
        defaults.blurSettings.blurIntensityRange,
      );
      s.blurSettings.setBlurContrastRange(
        defaults.blurSettings.blurContrastRange,
      );
      s.blurSettings.blurAnimated = defaults.blurSettings.blurAnimated;
      s.blurSettings.blurAnimOptions = AnimationOptions();
    });
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    _updateSettings((s) {
      s.blurEnabled = presetData['blurEnabled'] ?? s.blurEnabled;
      s.blurSettings.setBlurAmountRange(
        _rangeFromPreset(
          presetData,
          rangeKey: 'blurAmountRange',
          valueKey: 'blurAmount',
          minKey: 'blurAmountMin',
          maxKey: 'blurAmountMax',
          currentKey: 'blurAmountCurrent',
          hardMin: 0.0,
          hardMax: 1.0,
          defaultValue: s.blurSettings.blurAmount,
        ),
      );
      s.blurSettings.setBlurRadiusRange(
        _rangeFromPreset(
          presetData,
          rangeKey: 'blurRadiusRange',
          valueKey: 'blurRadius',
          minKey: 'blurRadiusMin',
          maxKey: 'blurRadiusMax',
          currentKey: 'blurRadiusCurrent',
          hardMin: 0.0,
          hardMax: 120.0,
          defaultValue: s.blurSettings.blurRadius,
        ),
      );
      s.blurSettings.setBlurOpacityRange(
        _rangeFromPreset(
          presetData,
          rangeKey: 'blurOpacityRange',
          valueKey: 'blurOpacity',
          minKey: 'blurOpacityMin',
          maxKey: 'blurOpacityMax',
          currentKey: 'blurOpacityCurrent',
          hardMin: 0.0,
          hardMax: 1.0,
          defaultValue: s.blurSettings.blurOpacity,
        ),
      );
      s.blurSettings.blurBlendMode =
          presetData['blurBlendMode'] ?? s.blurSettings.blurBlendMode;
      s.blurSettings.setBlurIntensityRange(
        _rangeFromPreset(
          presetData,
          rangeKey: 'blurIntensityRange',
          valueKey: 'blurIntensity',
          minKey: 'blurIntensityMin',
          maxKey: 'blurIntensityMax',
          currentKey: 'blurIntensityCurrent',
          hardMin: 0.0,
          hardMax: 3.0,
          defaultValue: s.blurSettings.blurIntensity,
        ),
      );
      s.blurSettings.setBlurContrastRange(
        _rangeFromPreset(
          presetData,
          rangeKey: 'blurContrastRange',
          valueKey: 'blurContrast',
          minKey: 'blurContrastMin',
          maxKey: 'blurContrastMax',
          currentKey: 'blurContrastCurrent',
          hardMin: 0.0,
          hardMax: 2.0,
          defaultValue: s.blurSettings.blurContrast,
        ),
      );
      s.blurSettings.blurAnimated =
          presetData['blurAnimated'] ?? s.blurSettings.blurAnimated;

      if (presetData['blurAnimOptions'] != null) {
        s.blurSettings.blurAnimOptions = AnimationOptions.fromMap(
          Map<String, dynamic>.from(presetData['blurAnimOptions']),
        );
      }
    });
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
    required double defaultValue,
  }) {
    final dynamic payload = presetData[rangeKey];
    final double fallback = _readDouble(
      presetData[valueKey],
      defaultValue,
    ).clamp(hardMin, hardMax)
        .toDouble();

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
    final amountRange = settings.blurSettings.blurAmountRange;
    final radiusRange = settings.blurSettings.blurRadiusRange;
    final opacityRange = settings.blurSettings.blurOpacityRange;
    final intensityRange = settings.blurSettings.blurIntensityRange;
    final contrastRange = settings.blurSettings.blurContrastRange;

    Map<String, dynamic> presetData = {
      'blurEnabled': settings.blurEnabled,
      'blurAmount': amountRange.userMax,
      'blurAmountMin': amountRange.userMin,
      'blurAmountMax': amountRange.userMax,
      'blurAmountCurrent': amountRange.current,
      'blurAmountRange': amountRange.toMap(),
      'blurRadius': radiusRange.userMax,
      'blurRadiusMin': radiusRange.userMin,
      'blurRadiusMax': radiusRange.userMax,
      'blurRadiusCurrent': radiusRange.current,
      'blurRadiusRange': radiusRange.toMap(),
      'blurOpacity': opacityRange.userMax,
      'blurOpacityMin': opacityRange.userMin,
      'blurOpacityMax': opacityRange.userMax,
      'blurOpacityCurrent': opacityRange.current,
      'blurOpacityRange': opacityRange.toMap(),
      'blurBlendMode': settings.blurSettings.blurBlendMode,
      'blurIntensity': intensityRange.userMax,
      'blurIntensityMin': intensityRange.userMin,
      'blurIntensityMax': intensityRange.userMax,
      'blurIntensityCurrent': intensityRange.current,
      'blurIntensityRange': intensityRange.toMap(),
      'blurContrast': contrastRange.userMax,
      'blurContrastMin': contrastRange.userMin,
      'blurContrastMax': contrastRange.userMax,
      'blurContrastCurrent': contrastRange.current,
      'blurContrastRange': contrastRange.toMap(),
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
    PresetRefreshService().refreshAspect(ShaderAspect.blur);
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
