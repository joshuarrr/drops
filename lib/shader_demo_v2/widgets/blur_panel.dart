import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../controllers/effect_controls_bridge.dart';
import '../models/animation_options.dart';
import '../models/presets_manager.dart';
import '../controllers/animation_state_manager.dart';
import 'lockable_slider.dart';
import 'animation_controls.dart';
import 'glass_panel.dart';
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
    return GlassPanel(
      child: Column(
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
          LockableSlider(
            label: 'Shatter Amount',
            value: settings.blurSettings.blurAmount,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            displayValue:
                '${(settings.blurSettings.blurAmount * 100).round()}%',
            onChanged: (value) => _onSliderChanged(
              value,
              (s, v) => s.blurSettings.blurAmount = v,
            ),
            activeColor: sliderColor,
            parameterId: ParameterIds.blurAmount,
            animationEnabled: settings.blurSettings.blurAnimated,
            defaultValue: 0.0,
          ),
          LockableSlider(
            label: 'Shatter Radius',
            value: settings.blurSettings.blurRadius,
            min: 0.0,
            max: 120.0,
            divisions: 120,
            displayValue: '${settings.blurSettings.blurRadius.round()}px',
            onChanged: (value) => _onSliderChanged(
              value,
              (s, v) => s.blurSettings.blurRadius = v,
            ),
            activeColor: sliderColor,
            parameterId: ParameterIds.blurRadius,
            animationEnabled: settings.blurSettings.blurAnimated,
            defaultValue: 15.0,
          ),
          LockableSlider(
            label: 'Shatter Opacity',
            value: settings.blurSettings.blurOpacity,
            min: 0.0,
            max: 1.0,
            divisions: 100,
            displayValue:
                '${(settings.blurSettings.blurOpacity * 100).round()}%',
            onChanged: (value) => _onSliderChanged(
              value,
              (s, v) => s.blurSettings.blurOpacity = v,
            ),
            activeColor: sliderColor,
            parameterId: ParameterIds.blurOpacity,
            animationEnabled: settings.blurSettings.blurAnimated,
            defaultValue: 1.0,
          ),
          LockableSlider(
            label: 'Intensity',
            value: settings.blurSettings.blurIntensity,
            min: 0.0,
            max: 3.0,
            divisions: null, // Removed divisions to get rid of dots
            displayValue:
                '${settings.blurSettings.blurIntensity.toStringAsFixed(1)}x',
            onChanged: (value) => _onSliderChanged(
              value,
              (s, v) => s.blurSettings.blurIntensity = v,
            ),
            activeColor: sliderColor,
            parameterId: ParameterIds.blurIntensity,
            animationEnabled: settings.blurSettings.blurAnimated,
            defaultValue: 1.0,
          ),
          LockableSlider(
            label: 'Contrast',
            value: settings.blurSettings.blurContrast,
            min: 0.0,
            max: 2.0,
            divisions: null, // Removed divisions to get rid of dots
            displayValue:
                '${(settings.blurSettings.blurContrast * 100).round()}%',
            onChanged: (value) => _onSliderChanged(
              value,
              (s, v) => s.blurSettings.blurContrast = v,
            ),
            activeColor: sliderColor,
            parameterId: ParameterIds.blurContrast,
            animationEnabled: settings.blurSettings.blurAnimated,
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
              Text(
                'Animate',
                style: TextStyle(color: sliderColor, fontSize: 14),
              ),
              Switch(
                value: settings.blurSettings.blurAnimated,
                thumbColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.selected)
                      ? sliderColor
                      : null,
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
                  s.blurSettings.blurAnimOptions = s
                      .blurSettings
                      .blurAnimOptions
                      .copyWith(speed: v);
                });
              },
              animationMode: settings.blurSettings.blurAnimOptions.mode,
              onModeChanged: (m) {
                _updateSettings((s) {
                  s.blurSettings.blurAnimOptions = s
                      .blurSettings
                      .blurAnimOptions
                      .copyWith(mode: m);
                });
              },
              animationEasing: settings.blurSettings.blurAnimOptions.easing,
              onEasingChanged: (e) {
                _updateSettings((s) {
                  s.blurSettings.blurAnimOptions = s
                      .blurSettings
                      .blurAnimOptions
                      .copyWith(easing: e);
                });
              },
              sliderColor: sliderColor,
            ),
        ],
      ),
    );
  }

  void _onSliderChanged(
    double value,
    void Function(ShaderSettings, double) setter,
  ) {
    _updateSettings((s) {
      // Enable the corresponding effect if it's not already enabled
      if (!s.blurEnabled) s.blurEnabled = true;

      // Update the setting value
      setter(s, value);
    });
  }

  void _resetBlur() {
    final defaults = ShaderSettings.defaults;
    _updateSettings((s) {
      s.blurEnabled = false;
      s.blurSettings.blurAmount = defaults.blurSettings.blurAmount;
      s.blurSettings.blurRadius = defaults.blurSettings.blurRadius;
      s.blurSettings.blurOpacity = defaults.blurSettings.blurOpacity;
      s.blurSettings.blurBlendMode = defaults.blurSettings.blurBlendMode;
      s.blurSettings.blurIntensity = defaults.blurSettings.blurIntensity;
      s.blurSettings.blurContrast = defaults.blurSettings.blurContrast;
      s.blurSettings.blurAnimated = false;
      s.blurSettings.blurAnimOptions = AnimationOptions();
    });
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    _updateSettings((s) {
      s.blurEnabled = presetData['blurEnabled'] ?? s.blurEnabled;
      s.blurSettings.blurAmount =
          presetData['blurAmount'] ?? s.blurSettings.blurAmount;
      s.blurSettings.blurRadius =
          presetData['blurRadius'] ?? s.blurSettings.blurRadius;
      s.blurSettings.blurOpacity =
          presetData['blurOpacity'] ?? s.blurSettings.blurOpacity;
      s.blurSettings.blurBlendMode =
          presetData['blurBlendMode'] ?? s.blurSettings.blurBlendMode;
      s.blurSettings.blurIntensity =
          presetData['blurIntensity'] ?? s.blurSettings.blurIntensity;
      s.blurSettings.blurContrast =
          presetData['blurContrast'] ?? s.blurSettings.blurContrast;
      s.blurSettings.blurAnimated =
          presetData['blurAnimated'] ?? s.blurSettings.blurAnimated;

      if (presetData['blurAnimOptions'] != null) {
        s.blurSettings.blurAnimOptions = AnimationOptions.fromMap(
          Map<String, dynamic>.from(presetData['blurAnimOptions']),
        );
      }
    });
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
