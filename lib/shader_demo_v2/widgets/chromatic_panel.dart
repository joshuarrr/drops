import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/chromatic_settings.dart';
import '../models/presets_manager.dart';
import 'labeled_slider.dart';
import 'lockable_slider.dart';
import 'labeled_switch.dart';
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
              // Remove the Enable/disable switch
              // The effect is now automatically enabled when the panel is visible
              SizedBox(height: 8),
              LockableSlider(
                label: 'Amount',
                value: widget.settings.chromaticSettings.amount,
                min: 0.0,
                max: 20.0,
                divisions: 200,
                displayValue: widget.settings.chromaticSettings.amount
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.chromaticSettings.amount = value;
                  updatedSettings.chromaticEnabled =
                      true; // Ensure it's enabled when values change
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.chromaticAmount,
                animationEnabled:
                    widget.settings.chromaticSettings.chromaticAnimated,
                defaultValue: 0.5,
              ),
              LockableSlider(
                label: 'Angle',
                value: widget.settings.chromaticSettings.angle,
                min: 0.0,
                max: 360.0,
                divisions: 36,
                displayValue:
                    '${widget.settings.chromaticSettings.angle.toInt()}°',
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.chromaticSettings.angle = value;
                  updatedSettings.chromaticEnabled =
                      true; // Ensure it's enabled when values change
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.chromaticAngle,
                animationEnabled:
                    widget.settings.chromaticSettings.chromaticAnimated,
                defaultValue: 0.0,
              ),
              LockableSlider(
                label: 'Spread',
                value: widget.settings.chromaticSettings.spread,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: widget.settings.chromaticSettings.spread
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.chromaticSettings.spread = value;
                  updatedSettings.chromaticEnabled =
                      true; // Ensure it's enabled when values change
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.chromaticSpread,
                animationEnabled:
                    widget.settings.chromaticSettings.chromaticAnimated,
                defaultValue: 0.5,
              ),
              LockableSlider(
                label: 'Intensity',
                value: widget.settings.chromaticSettings.intensity,
                min: 0.0,
                max: 1.0,
                divisions: 100,
                displayValue: widget.settings.chromaticSettings.intensity
                    .toStringAsFixed(2),
                onChanged: (value) {
                  final updatedSettings = widget.settings;
                  updatedSettings.chromaticSettings.intensity = value;
                  updatedSettings.chromaticEnabled =
                      true; // Ensure it's enabled when values change
                  widget.onSettingsChanged(updatedSettings);
                },
                activeColor: widget.sliderColor,
                parameterId: ParameterIds.chromaticIntensity,
                animationEnabled:
                    widget.settings.chromaticSettings.chromaticAnimated,
                defaultValue: 0.5,
              ),

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

  void _resetChromatic() {
    final defaultSettings = ChromaticSettings();
    widget.settings.chromaticEnabled = true; // Keep enabled, just reset values
    widget.settings.chromaticSettings.amount = defaultSettings.amount;
    widget.settings.chromaticSettings.angle = defaultSettings.angle;
    widget.settings.chromaticSettings.spread = defaultSettings.spread;
    widget.settings.chromaticSettings.intensity = defaultSettings.intensity;
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

    if (presetData.containsKey('amount')) {
      widget.settings.chromaticSettings.amount = presetData['amount'];
    }
    if (presetData.containsKey('angle')) {
      widget.settings.chromaticSettings.angle = presetData['angle'];
    }
    if (presetData.containsKey('spread')) {
      widget.settings.chromaticSettings.spread = presetData['spread'];
    }
    if (presetData.containsKey('intensity')) {
      widget.settings.chromaticSettings.intensity = presetData['intensity'];
    }
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
      'angle': widget.settings.chromaticSettings.angle,
      'spread': widget.settings.chromaticSettings.spread,
      'intensity': widget.settings.chromaticSettings.intensity,
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
