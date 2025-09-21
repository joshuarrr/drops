import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/presets_manager.dart';
import '../services/preset_refresh_service.dart';
import 'lockable_slider.dart';
import 'range_lockable_slider.dart';
import '../controllers/animation_state_manager.dart';
import '../models/parameter_range.dart';

import 'animation_controls.dart';
import 'enhanced_panel_header.dart';

class RipplePanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const RipplePanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<RipplePanel> createState() => _RipplePanelState();
}

class _RipplePanelState extends State<RipplePanel> {
  // Add static fields for presets
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnhancedPanelHeader(
          aspect: ShaderAspect.ripple,
          onPresetSelected: _applyPreset,
          onReset: _resetRipple,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: widget.settings.rippleSettings.applyToImage,
          applyToText: widget.settings.rippleSettings.applyToText,
          onApplyToImageChanged: (value) {
            widget.settings.rippleSettings.applyToImage = value;
            widget.onSettingsChanged(widget.settings);
          },
          onApplyToTextChanged: (value) {
            widget.settings.rippleSettings.applyToText = value;
            widget.onSettingsChanged(widget.settings);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Removed the Enable Ripple Effect toggle as requested
              // The effect is now automatically enabled when any parameter is changed

              // Number of drops with randomize button
              Row(
                children: [
                  Expanded(
                    child: LockableSlider(
                      label: 'Number of Drops',
                      value: widget.settings.rippleSettings.rippleDropCount
                          .toDouble(),
                      min: 1.0,
                      max: 30.0,
                      divisions: 29,
                      displayValue: widget
                          .settings
                          .rippleSettings
                          .rippleDropCount
                          .toString(),
                      onChanged: (value) {
                        final updatedSettings = widget.settings;
                        updatedSettings.rippleSettings.rippleDropCount = value
                            .round();
                        updatedSettings.rippleEnabled =
                            true; // Ensure it's enabled
                        widget.onSettingsChanged(updatedSettings);
                      },
                      activeColor: widget.sliderColor,
                      parameterId: ParameterIds.rippleDropCount,
                      animationEnabled:
                          widget.settings.rippleSettings.rippleAnimated,
                      defaultValue: 5.0,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.shuffle, color: widget.sliderColor),
                    tooltip: 'Randomize drop positions',
                    onPressed: () {
                      final updatedSettings = widget.settings;
                      updatedSettings.rippleSettings.randomizeDropPositions();
                      updatedSettings.rippleEnabled =
                          true; // Ensure it's enabled
                      widget.onSettingsChanged(updatedSettings);
                    },
                  ),
                ],
              ),

              RangeLockableSlider(
                label: 'Ovalness',
                range: widget.settings.rippleSettings.rippleOvalnessRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(2),
                defaults:
                    ShaderSettings.defaults.rippleSettings.rippleOvalnessRange,
                parameterId: ParameterIds.rippleOvalness,
                animationEnabled: widget.settings.rippleSettings.rippleAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.setRippleOvalnessRange(range);
                  updatedSettings.rippleEnabled = true;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              RangeLockableSlider(
                label: 'Rotation',
                range: widget.settings.rippleSettings.rippleRotationRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(2),
                defaults:
                    ShaderSettings.defaults.rippleSettings.rippleRotationRange,
                parameterId: ParameterIds.rippleRotation,
                animationEnabled: widget.settings.rippleSettings.rippleAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.setRippleRotationRange(range);
                  updatedSettings.rippleEnabled = true;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              RangeLockableSlider(
                label: 'Intensity',
                range: widget.settings.rippleSettings.rippleIntensityRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(2),
                defaults:
                    ShaderSettings.defaults.rippleSettings.rippleIntensityRange,
                parameterId: ParameterIds.rippleIntensity,
                animationEnabled: widget.settings.rippleSettings.rippleAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.setRippleIntensityRange(range);
                  updatedSettings.rippleEnabled = true;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              RangeLockableSlider(
                label: 'Size',
                range: widget.settings.rippleSettings.rippleSizeRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(2),
                defaults:
                    ShaderSettings.defaults.rippleSettings.rippleSizeRange,
                parameterId: ParameterIds.rippleSize,
                animationEnabled: widget.settings.rippleSettings.rippleAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.setRippleSizeRange(range);
                  updatedSettings.rippleEnabled = true;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              RangeLockableSlider(
                label: 'Speed',
                range: widget.settings.rippleSettings.rippleSpeedRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(2),
                defaults:
                    ShaderSettings.defaults.rippleSettings.rippleSpeedRange,
                parameterId: ParameterIds.rippleSpeed,
                animationEnabled: widget.settings.rippleSettings.rippleAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.setRippleSpeedRange(range);
                  updatedSettings.rippleEnabled = true;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              RangeLockableSlider(
                label: 'Opacity',
                range: widget.settings.rippleSettings.rippleOpacityRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(2),
                defaults:
                    ShaderSettings.defaults.rippleSettings.rippleOpacityRange,
                parameterId: ParameterIds.rippleOpacity,
                animationEnabled: widget.settings.rippleSettings.rippleAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.setRippleOpacityRange(range);
                  updatedSettings.rippleEnabled = true;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              RangeLockableSlider(
                label: 'Color',
                range: widget.settings.rippleSettings.rippleColorRange,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                activeColor: widget.sliderColor,
                formatValue: (v) => v.toStringAsFixed(2),
                defaults:
                    ShaderSettings.defaults.rippleSettings.rippleColorRange,
                parameterId: ParameterIds.rippleColor,
                animationEnabled: widget.settings.rippleSettings.rippleAnimated,
                onRangeChanged: (range) {
                  final updatedSettings = widget.settings;
                  updatedSettings.rippleSettings.setRippleColorRange(range);
                  updatedSettings.rippleEnabled = true;
                  widget.onSettingsChanged(updatedSettings);
                },
              ),

              SizedBox(height: 16),

              // Toggle animation for ripple effect (moved to bottom as requested)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Animate Effect',
                    style: TextStyle(color: widget.sliderColor, fontSize: 14),
                  ),
                  Switch(
                    value: widget.settings.rippleSettings.rippleAnimated,
                    activeColor: widget.sliderColor,
                    onChanged: (value) {
                      final updatedSettings = widget.settings;
                      updatedSettings.rippleSettings.rippleAnimated = value;
                      // Always ensure the effect is enabled when animation is toggled
                      updatedSettings.rippleEnabled = true;
                      widget.onSettingsChanged(updatedSettings);
                    },
                  ),
                ],
              ),

              // Only show animation controls when animation is enabled
              if (widget.settings.rippleSettings.rippleAnimated)
                AnimationControls(
                  animationSpeed:
                      widget.settings.rippleSettings.rippleAnimOptions.speed,
                  animationMode:
                      widget.settings.rippleSettings.rippleAnimOptions.mode,
                  animationEasing:
                      widget.settings.rippleSettings.rippleAnimOptions.easing,
                  onSpeedChanged: (v) {
                    widget.settings.rippleSettings.rippleAnimOptions = widget
                        .settings
                        .rippleSettings
                        .rippleAnimOptions
                        .copyWith(speed: v);
                    widget.settings.rippleEnabled =
                        true; // Ensure it's enabled when values change
                    widget.onSettingsChanged(widget.settings);
                  },
                  onModeChanged: (m) {
                    widget.settings.rippleSettings.rippleAnimOptions = widget
                        .settings
                        .rippleSettings
                        .rippleAnimOptions
                        .copyWith(mode: m);
                    widget.settings.rippleEnabled =
                        true; // Ensure it's enabled when values change
                    widget.onSettingsChanged(widget.settings);
                  },
                  onEasingChanged: (e) {
                    widget.settings.rippleSettings.rippleAnimOptions = widget
                        .settings
                        .rippleSettings
                        .rippleAnimOptions
                        .copyWith(easing: e);
                    widget.settings.rippleEnabled =
                        true; // Ensure it's enabled when values change
                    widget.onSettingsChanged(widget.settings);
                  },
                  sliderColor: widget.sliderColor,
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _resetRipple() {
    final defaults = ShaderSettings.defaults.rippleSettings;
    widget.settings.rippleEnabled = false;
    widget.settings.rippleSettings.setRippleIntensityRange(
      defaults.rippleIntensityRange,
    );
    widget.settings.rippleSettings.setRippleSizeRange(defaults.rippleSizeRange);
    widget.settings.rippleSettings.setRippleSpeedRange(
      defaults.rippleSpeedRange,
    );
    widget.settings.rippleSettings.setRippleOpacityRange(
      defaults.rippleOpacityRange,
    );
    widget.settings.rippleSettings.setRippleColorRange(
      defaults.rippleColorRange,
    );
    widget.settings.rippleSettings.rippleDropCount = defaults.rippleDropCount;
    widget.settings.rippleSettings.setRippleOvalnessRange(
      defaults.rippleOvalnessRange,
    );
    widget.settings.rippleSettings.setRippleRotationRange(
      defaults.rippleRotationRange,
    );
    widget.settings.rippleSettings.rippleAnimated = false;
    widget.settings.rippleSettings.applyToImage = true;
    widget.settings.rippleSettings.applyToText = true;

    // Clear animation locks for ripple parameters
    final animationManager = AnimationStateManager();
    animationManager.clearLocksForEffect('ripple.');

    widget.onSettingsChanged(widget.settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    if (presetData.containsKey('rippleEnabled')) {
      widget.settings.rippleEnabled = presetData['rippleEnabled'];
    }
    widget.settings.rippleSettings.setRippleIntensityRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'rippleIntensityRange',
        valueKey: 'rippleIntensity',
        minKey: 'rippleIntensityMin',
        maxKey: 'rippleIntensityMax',
        currentKey: 'rippleIntensityCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: widget.settings.rippleSettings.rippleIntensity,
      ),
    );
    widget.settings.rippleSettings.setRippleSizeRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'rippleSizeRange',
        valueKey: 'rippleSize',
        minKey: 'rippleSizeMin',
        maxKey: 'rippleSizeMax',
        currentKey: 'rippleSizeCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: widget.settings.rippleSettings.rippleSize,
      ),
    );
    widget.settings.rippleSettings.setRippleSpeedRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'rippleSpeedRange',
        valueKey: 'rippleSpeed',
        minKey: 'rippleSpeedMin',
        maxKey: 'rippleSpeedMax',
        currentKey: 'rippleSpeedCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: widget.settings.rippleSettings.rippleSpeed,
      ),
    );
    widget.settings.rippleSettings.setRippleOpacityRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'rippleOpacityRange',
        valueKey: 'rippleOpacity',
        minKey: 'rippleOpacityMin',
        maxKey: 'rippleOpacityMax',
        currentKey: 'rippleOpacityCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: widget.settings.rippleSettings.rippleOpacity,
      ),
    );
    widget.settings.rippleSettings.setRippleColorRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'rippleColorRange',
        valueKey: 'rippleColor',
        minKey: 'rippleColorMin',
        maxKey: 'rippleColorMax',
        currentKey: 'rippleColorCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: widget.settings.rippleSettings.rippleColor,
      ),
    );
    if (presetData.containsKey('rippleDropCount')) {
      widget.settings.rippleSettings.rippleDropCount =
          presetData['rippleDropCount'];
    }
    widget.settings.rippleSettings.setRippleOvalnessRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'rippleOvalnessRange',
        valueKey: 'rippleOvalness',
        minKey: 'rippleOvalnessMin',
        maxKey: 'rippleOvalnessMax',
        currentKey: 'rippleOvalnessCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: widget.settings.rippleSettings.rippleOvalness,
      ),
    );
    widget.settings.rippleSettings.setRippleRotationRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'rippleRotationRange',
        valueKey: 'rippleRotation',
        minKey: 'rippleRotationMin',
        maxKey: 'rippleRotationMax',
        currentKey: 'rippleRotationCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: widget.settings.rippleSettings.rippleRotation,
      ),
    );
    if (presetData.containsKey('rippleAnimated')) {
      widget.settings.rippleSettings.rippleAnimated =
          presetData['rippleAnimated'];
    }
    if (presetData.containsKey('applyToImage')) {
      widget.settings.rippleSettings.applyToImage = presetData['applyToImage'];
    }
    if (presetData.containsKey('applyToText')) {
      widget.settings.rippleSettings.applyToText = presetData['applyToText'];
    }
    widget.onSettingsChanged(widget.settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'rippleEnabled': widget.settings.rippleEnabled,
      'rippleIntensity': widget.settings.rippleSettings.rippleIntensity,
      'rippleIntensityMin':
          widget.settings.rippleSettings.rippleIntensityRange.userMin,
      'rippleIntensityMax':
          widget.settings.rippleSettings.rippleIntensityRange.userMax,
      'rippleIntensityCurrent':
          widget.settings.rippleSettings.rippleIntensityRange.current,
      'rippleIntensityRange': widget
          .settings
          .rippleSettings
          .rippleIntensityRange
          .toMap(),
      'rippleSize': widget.settings.rippleSettings.rippleSize,
      'rippleSizeMin': widget.settings.rippleSettings.rippleSizeRange.userMin,
      'rippleSizeMax': widget.settings.rippleSettings.rippleSizeRange.userMax,
      'rippleSizeCurrent':
          widget.settings.rippleSettings.rippleSizeRange.current,
      'rippleSizeRange': widget.settings.rippleSettings.rippleSizeRange.toMap(),
      'rippleSpeed': widget.settings.rippleSettings.rippleSpeed,
      'rippleSpeedMin': widget.settings.rippleSettings.rippleSpeedRange.userMin,
      'rippleSpeedMax': widget.settings.rippleSettings.rippleSpeedRange.userMax,
      'rippleSpeedCurrent':
          widget.settings.rippleSettings.rippleSpeedRange.current,
      'rippleSpeedRange': widget.settings.rippleSettings.rippleSpeedRange
          .toMap(),
      'rippleOpacity': widget.settings.rippleSettings.rippleOpacity,
      'rippleOpacityMin':
          widget.settings.rippleSettings.rippleOpacityRange.userMin,
      'rippleOpacityMax':
          widget.settings.rippleSettings.rippleOpacityRange.userMax,
      'rippleOpacityCurrent':
          widget.settings.rippleSettings.rippleOpacityRange.current,
      'rippleOpacityRange': widget.settings.rippleSettings.rippleOpacityRange
          .toMap(),
      'rippleColor': widget.settings.rippleSettings.rippleColor,
      'rippleColorMin': widget.settings.rippleSettings.rippleColorRange.userMin,
      'rippleColorMax': widget.settings.rippleSettings.rippleColorRange.userMax,
      'rippleColorCurrent':
          widget.settings.rippleSettings.rippleColorRange.current,
      'rippleColorRange': widget.settings.rippleSettings.rippleColorRange
          .toMap(),
      'rippleDropCount': widget.settings.rippleSettings.rippleDropCount,
      'rippleOvalness': widget.settings.rippleSettings.rippleOvalness,
      'rippleOvalnessMin':
          widget.settings.rippleSettings.rippleOvalnessRange.userMin,
      'rippleOvalnessMax':
          widget.settings.rippleSettings.rippleOvalnessRange.userMax,
      'rippleOvalnessCurrent':
          widget.settings.rippleSettings.rippleOvalnessRange.current,
      'rippleOvalnessRange': widget.settings.rippleSettings.rippleOvalnessRange
          .toMap(),
      'rippleRotation': widget.settings.rippleSettings.rippleRotation,
      'rippleRotationMin':
          widget.settings.rippleSettings.rippleRotationRange.userMin,
      'rippleRotationMax':
          widget.settings.rippleSettings.rippleRotationRange.userMax,
      'rippleRotationCurrent':
          widget.settings.rippleSettings.rippleRotationRange.current,
      'rippleRotationRange': widget.settings.rippleSettings.rippleRotationRange
          .toMap(),
      'rippleAnimated': widget.settings.rippleSettings.rippleAnimated,
      'applyToImage': widget.settings.rippleSettings.applyToImage,
      'applyToText': widget.settings.rippleSettings.applyToText,
    };

    bool success = await PresetsManager.savePreset(aspect, name, presetData);

    if (success) {
      // Update cached presets
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      // Force refresh of the UI to show the new preset immediately
      _refreshPresets();
    }
  }

  static Future<Map<String, dynamic>> _loadPresetsForAspect(
    ShaderAspect aspect,
  ) async {
    if (!_cachedPresets.containsKey(aspect)) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
    }
    return _cachedPresets[aspect] ?? {};
  }

  static void _refreshPresets() {
    _refreshCounter++;
    // Call the central refresh method for immediate UI update
    PresetRefreshService().refreshAspect(ShaderAspect.ripple);
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
    ).clamp(hardMin, hardMax).toDouble();

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
    ).clamp(hardMin, hardMax).toDouble();
    final double userMax = _readDouble(
      presetData[maxKey],
      fallback,
    ).clamp(hardMin, hardMax).toDouble();
    final double current = _readDouble(
      presetData[currentKey],
      fallback,
    ).clamp(hardMin, hardMax).toDouble();

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
}
