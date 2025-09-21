import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/chromatic_settings.dart';
import '../models/presets_manager.dart';
import '../services/preset_refresh_service.dart';
import '../models/parameter_range.dart';
import 'range_lockable_slider.dart';
import 'animation_controls.dart';
import 'enhanced_panel_header.dart';
import '../controllers/animation_state_manager.dart';
import '../views/effect_controls.dart';

class ChromaticPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;

  const ChromaticPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
  }) : super(key: key);

  @override
  State<ChromaticPanel> createState() => _ChromaticPanelState();
}

class _ChromaticPanelState extends State<ChromaticPanel> {
  // Add static fields for presets
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

  @override
  void initState() {
    super.initState();
    // Ensure chromatic effect is enabled when panel is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.settings.chromaticEnabled) {
        final updatedSettings = widget.settings;
        updatedSettings.chromaticEnabled = true;
        widget.onSettingsChanged(updatedSettings);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chromaticSettings = widget.settings.chromaticSettings;
    final chromaticDefaults = ShaderSettings.defaults.chromaticSettings;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EnhancedPanelHeader(
          aspect: ShaderAspect.chromatic,
          onPresetSelected: _applyPreset,
          onReset: _resetChromatic,
          onSavePreset: _savePresetForAspect,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: widget.settings.chromaticSettings.applyToImage,
          applyToText: widget.settings.chromaticSettings.applyToText,
          onApplyToImageChanged: (value) {
            widget.settings.chromaticSettings.applyToImage = value;
            widget.onSettingsChanged(widget.settings);
          },
          onApplyToTextChanged: (value) {
            widget.settings.chromaticSettings.applyToText = value;
            widget.onSettingsChanged(widget.settings);
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              ..._buildRangeSliders(chromaticSettings, chromaticDefaults),

              // Toggle animation for chromatic effect
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Animate Effect',
                    style: TextStyle(color: widget.sliderColor, fontSize: 14),
                  ),
                  Switch(
                    value: widget.settings.chromaticSettings.chromaticAnimated,
                    activeColor: widget.sliderColor,
                    onChanged: (value) {
                      final updatedSettings = widget.settings;
                      updatedSettings.chromaticSettings.chromaticAnimated =
                          value;
                      // Always ensure the effect is enabled when animation is toggled
                      updatedSettings.chromaticEnabled = true;
                      widget.onSettingsChanged(updatedSettings);
                    },
                  ),
                ],
              ),

              // Only show animation controls when animation is enabled
              if (widget.settings.chromaticSettings.chromaticAnimated)
                // Add animation controls for chromatic effect
                AnimationControls(
                  animationSpeed:
                      widget.settings.chromaticSettings.animOptions.speed,
                  onSpeedChanged: (v) {
                    widget.settings.chromaticSettings.animOptions = widget
                        .settings
                        .chromaticSettings
                        .animOptions
                        .copyWith(speed: v);
                    widget.settings.chromaticEnabled =
                        true; // Ensure it's enabled when values change
                    widget.onSettingsChanged(widget.settings);
                  },
                  animationMode:
                      widget.settings.chromaticSettings.animOptions.mode,
                  onModeChanged: (m) {
                    widget.settings.chromaticSettings.animOptions = widget
                        .settings
                        .chromaticSettings
                        .animOptions
                        .copyWith(mode: m);
                    widget.settings.chromaticEnabled =
                        true; // Ensure it's enabled when values change
                    widget.onSettingsChanged(widget.settings);
                  },
                  animationEasing:
                      widget.settings.chromaticSettings.animOptions.easing,
                  onEasingChanged: (e) {
                    widget.settings.chromaticSettings.animOptions = widget
                        .settings
                        .chromaticSettings
                        .animOptions
                        .copyWith(easing: e);
                    widget.settings.chromaticEnabled =
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

  List<Widget> _buildRangeSliders(
    ChromaticSettings settings,
    ChromaticSettings defaults,
  ) {
    String formatAmount(double value) => value.toStringAsFixed(2);
    String formatAngle(double value) => '${value.toStringAsFixed(0)}°';
    String formatFraction(double value) => value.toStringAsFixed(2);

    return [
      RangeLockableSlider(
        label: 'Amount',
        range: settings.amountRange,
        min: 0.0,
        max: 20.0,
        divisions: 200,
        activeColor: widget.sliderColor,
        formatValue: formatAmount,
        defaults: defaults.amountRange,
        parameterId: ParameterIds.chromaticAmount,
        animationEnabled: settings.chromaticAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (s, updated) => s.setAmountRange(updated),
        ),
      ),
      RangeLockableSlider(
        label: 'Angle',
        range: settings.angleRange,
        min: 0.0,
        max: 360.0,
        divisions: 360,
        activeColor: widget.sliderColor,
        formatValue: formatAngle,
        defaults: defaults.angleRange,
        parameterId: ParameterIds.chromaticAngle,
        animationEnabled: settings.chromaticAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (s, updated) => s.setAngleRange(updated),
        ),
      ),
      RangeLockableSlider(
        label: 'Spread',
        range: settings.spreadRange,
        min: 0.0,
        max: 1.0,
        divisions: 100,
        activeColor: widget.sliderColor,
        formatValue: formatFraction,
        defaults: defaults.spreadRange,
        parameterId: ParameterIds.chromaticSpread,
        animationEnabled: settings.chromaticAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (s, updated) => s.setSpreadRange(updated),
        ),
      ),
      RangeLockableSlider(
        label: 'Intensity',
        range: settings.intensityRange,
        min: 0.0,
        max: 1.0,
        divisions: 100,
        activeColor: widget.sliderColor,
        formatValue: formatFraction,
        defaults: defaults.intensityRange,
        parameterId: ParameterIds.chromaticIntensity,
        animationEnabled: settings.chromaticAnimated,
        onRangeChanged: (range) => _onRangeChanged(
          range,
          (s, updated) => s.setIntensityRange(updated),
        ),
      ),
    ];
  }

  void _onRangeChanged(
    ParameterRange range,
    void Function(ChromaticSettings, ParameterRange) setter,
  ) {
    setter(widget.settings.chromaticSettings, range);
    widget.settings.chromaticEnabled = true;
    widget.onSettingsChanged(widget.settings);
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
    final double fallback = _readDouble(presetData[valueKey], fallbackValue)
        .clamp(hardMin, hardMax)
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

    final double userMin = _readDouble(presetData[minKey], hardMin)
        .clamp(hardMin, hardMax)
        .toDouble();
    final double userMax = _readDouble(presetData[maxKey], fallback)
        .clamp(hardMin, hardMax)
        .toDouble();
    final double current = _readDouble(presetData[currentKey], fallback)
        .clamp(hardMin, hardMax)
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

  void _resetChromatic() {
    final defaults = ShaderSettings.defaults.chromaticSettings;
    widget.settings.chromaticEnabled = true; // Keep enabled, just reset values
    widget.settings.chromaticSettings.setAmountRange(defaults.amountRange);
    widget.settings.chromaticSettings.setAngleRange(defaults.angleRange);
    widget.settings.chromaticSettings.setSpreadRange(defaults.spreadRange);
    widget.settings.chromaticSettings.setIntensityRange(defaults.intensityRange);
    widget.settings.chromaticSettings.chromaticAnimated = false;
    widget.settings.chromaticSettings.applyToImage = true;
    widget.settings.chromaticSettings.applyToText = true;

    // Clear animation locks for chromatic parameters
    final animationManager = AnimationStateManager();
    animationManager.clearLocksForEffect('chromatic.');

    widget.onSettingsChanged(widget.settings);
  }

  void _applyPreset(Map<String, dynamic> presetData) {
    // Always enable the effect when applying a preset
    widget.settings.chromaticEnabled = true;

    widget.settings.chromaticSettings.setAmountRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'amountRange',
        valueKey: 'amount',
        minKey: 'amountMin',
        maxKey: 'amountMax',
        currentKey: 'amountCurrent',
        hardMin: 0.0,
        hardMax: 20.0,
        fallbackValue: widget.settings.chromaticSettings.amount,
      ),
    );
    widget.settings.chromaticSettings.setAngleRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'angleRange',
        valueKey: 'angle',
        minKey: 'angleMin',
        maxKey: 'angleMax',
        currentKey: 'angleCurrent',
        hardMin: 0.0,
        hardMax: 360.0,
        fallbackValue: widget.settings.chromaticSettings.angle,
      ),
    );
    widget.settings.chromaticSettings.setSpreadRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'spreadRange',
        valueKey: 'spread',
        minKey: 'spreadMin',
        maxKey: 'spreadMax',
        currentKey: 'spreadCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: widget.settings.chromaticSettings.spread,
      ),
    );
    widget.settings.chromaticSettings.setIntensityRange(
      _rangeFromPreset(
        presetData,
        rangeKey: 'intensityRange',
        valueKey: 'intensity',
        minKey: 'intensityMin',
        maxKey: 'intensityMax',
        currentKey: 'intensityCurrent',
        hardMin: 0.0,
        hardMax: 1.0,
        fallbackValue: widget.settings.chromaticSettings.intensity,
      ),
    );
    if (presetData.containsKey('chromaticAnimated')) {
      widget.settings.chromaticSettings.chromaticAnimated =
          presetData['chromaticAnimated'];
    }
    if (presetData.containsKey('applyToImage')) {
      widget.settings.chromaticSettings.applyToImage =
          presetData['applyToImage'];
    }
    if (presetData.containsKey('applyToText')) {
      widget.settings.chromaticSettings.applyToText = presetData['applyToText'];
    }
    widget.onSettingsChanged(widget.settings);
  }

  Future<void> _savePresetForAspect(ShaderAspect aspect, String name) async {
    Map<String, dynamic> presetData = {
      'amount': widget.settings.chromaticSettings.amount,
      'amountMin': widget.settings.chromaticSettings.amountRange.userMin,
      'amountMax': widget.settings.chromaticSettings.amountRange.userMax,
      'amountCurrent': widget.settings.chromaticSettings.amountRange.current,
      'amountRange': widget.settings.chromaticSettings.amountRange.toMap(),
      'angle': widget.settings.chromaticSettings.angle,
      'angleMin': widget.settings.chromaticSettings.angleRange.userMin,
      'angleMax': widget.settings.chromaticSettings.angleRange.userMax,
      'angleCurrent': widget.settings.chromaticSettings.angleRange.current,
      'angleRange': widget.settings.chromaticSettings.angleRange.toMap(),
      'spread': widget.settings.chromaticSettings.spread,
      'spreadMin': widget.settings.chromaticSettings.spreadRange.userMin,
      'spreadMax': widget.settings.chromaticSettings.spreadRange.userMax,
      'spreadCurrent': widget.settings.chromaticSettings.spreadRange.current,
      'spreadRange': widget.settings.chromaticSettings.spreadRange.toMap(),
      'intensity': widget.settings.chromaticSettings.intensity,
      'intensityMin': widget.settings.chromaticSettings.intensityRange.userMin,
      'intensityMax': widget.settings.chromaticSettings.intensityRange.userMax,
      'intensityCurrent': widget.settings.chromaticSettings.intensityRange.current,
      'intensityRange': widget.settings.chromaticSettings.intensityRange.toMap(),
      'chromaticAnimated': widget.settings.chromaticSettings.chromaticAnimated,
      'applyToImage': widget.settings.chromaticSettings.applyToImage,
      'applyToText': widget.settings.chromaticSettings.applyToText,
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
    PresetRefreshService().refreshAspect(ShaderAspect.chromatic);
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
