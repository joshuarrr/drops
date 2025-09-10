import 'package:flutter/material.dart';
import '../models/shader_effect.dart';
import '../models/effect_settings.dart';
import '../models/ripple_settings.dart';
import '../models/presets_manager.dart';
import 'lockable_slider.dart';
import '../controllers/animation_state_manager.dart';

import 'animation_controls.dart';
import 'enhanced_panel_header.dart';
import 'glass_panel.dart';

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
    return GlassPanel(
      child: Column(
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

                LockableSlider(
                  label: 'Ovalness',
                  value: widget.settings.rippleSettings.rippleOvalness,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  displayValue: widget.settings.rippleSettings.rippleOvalness
                      .toStringAsFixed(2),
                  onChanged: (value) {
                    final updatedSettings = widget.settings;
                    updatedSettings.rippleSettings.rippleOvalness = value;
                    updatedSettings.rippleEnabled = true; // Ensure it's enabled
                    widget.onSettingsChanged(updatedSettings);
                  },
                  activeColor: widget.sliderColor,
                  parameterId: ParameterIds.rippleOvalness,
                  animationEnabled:
                      widget.settings.rippleSettings.rippleAnimated,
                  defaultValue: 0.0,
                ),

                LockableSlider(
                  label: 'Rotation',
                  value: widget.settings.rippleSettings.rippleRotation,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  displayValue: widget.settings.rippleSettings.rippleRotation
                      .toStringAsFixed(2),
                  onChanged: (value) {
                    final updatedSettings = widget.settings;
                    updatedSettings.rippleSettings.rippleRotation = value;
                    updatedSettings.rippleEnabled = true; // Ensure it's enabled
                    widget.onSettingsChanged(updatedSettings);
                  },
                  activeColor: widget.sliderColor,
                  parameterId: ParameterIds.rippleRotation,
                  animationEnabled:
                      widget.settings.rippleSettings.rippleAnimated,
                  defaultValue: 0.0,
                ),

                LockableSlider(
                  label: 'Intensity',
                  value: widget.settings.rippleSettings.rippleIntensity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  displayValue: widget.settings.rippleSettings.rippleIntensity
                      .toStringAsFixed(2),
                  onChanged: (value) {
                    final updatedSettings = widget.settings;
                    updatedSettings.rippleSettings.rippleIntensity = value;
                    updatedSettings.rippleEnabled = true; // Ensure it's enabled
                    widget.onSettingsChanged(updatedSettings);
                  },
                  activeColor: widget.sliderColor,
                  parameterId: ParameterIds.rippleIntensity,
                  animationEnabled:
                      widget.settings.rippleSettings.rippleAnimated,
                  defaultValue: 0.5,
                ),

                LockableSlider(
                  label: 'Size',
                  value: widget.settings.rippleSettings.rippleSize,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  displayValue: widget.settings.rippleSettings.rippleSize
                      .toStringAsFixed(2),
                  onChanged: (value) {
                    final updatedSettings = widget.settings;
                    updatedSettings.rippleSettings.rippleSize = value;
                    updatedSettings.rippleEnabled = true; // Ensure it's enabled
                    widget.onSettingsChanged(updatedSettings);
                  },
                  activeColor: widget.sliderColor,
                  parameterId: ParameterIds.rippleSize,
                  animationEnabled:
                      widget.settings.rippleSettings.rippleAnimated,
                  defaultValue: 0.5,
                ),

                LockableSlider(
                  label: 'Speed',
                  value: widget.settings.rippleSettings.rippleSpeed,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  displayValue: widget.settings.rippleSettings.rippleSpeed
                      .toStringAsFixed(2),
                  onChanged: (value) {
                    final updatedSettings = widget.settings;
                    updatedSettings.rippleSettings.rippleSpeed = value;
                    updatedSettings.rippleEnabled = true; // Ensure it's enabled
                    widget.onSettingsChanged(updatedSettings);
                  },
                  activeColor: widget.sliderColor,
                  parameterId: ParameterIds.rippleSpeed,
                  animationEnabled:
                      widget.settings.rippleSettings.rippleAnimated,
                  defaultValue: 0.5,
                ),

                LockableSlider(
                  label: 'Opacity',
                  value: widget.settings.rippleSettings.rippleOpacity,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  displayValue: widget.settings.rippleSettings.rippleOpacity
                      .toStringAsFixed(2),
                  onChanged: (value) {
                    final updatedSettings = widget.settings;
                    updatedSettings.rippleSettings.rippleOpacity = value;
                    updatedSettings.rippleEnabled = true; // Ensure it's enabled
                    widget.onSettingsChanged(updatedSettings);
                  },
                  activeColor: widget.sliderColor,
                  parameterId: ParameterIds.rippleOpacity,
                  animationEnabled:
                      widget.settings.rippleSettings.rippleAnimated,
                  defaultValue: 0.8,
                ),

                LockableSlider(
                  label: 'Color',
                  value: widget.settings.rippleSettings.rippleColor,
                  min: 0.0,
                  max: 1.0,
                  divisions: 100,
                  displayValue: widget.settings.rippleSettings.rippleColor
                      .toStringAsFixed(2),
                  onChanged: (value) {
                    final updatedSettings = widget.settings;
                    updatedSettings.rippleSettings.rippleColor = value;
                    updatedSettings.rippleEnabled = true; // Ensure it's enabled
                    widget.onSettingsChanged(updatedSettings);
                  },
                  activeColor: widget.sliderColor,
                  parameterId: ParameterIds.rippleColor,
                  animationEnabled:
                      widget.settings.rippleSettings.rippleAnimated,
                  defaultValue: 0.5,
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
      ),
    );
  }

  void _resetRipple() {
    final defaultSettings = RippleSettings();
    widget.settings.rippleEnabled = false;
    widget.settings.rippleSettings.rippleIntensity =
        defaultSettings.rippleIntensity;
    widget.settings.rippleSettings.rippleSize = defaultSettings.rippleSize;
    widget.settings.rippleSettings.rippleSpeed = defaultSettings.rippleSpeed;
    widget.settings.rippleSettings.rippleOpacity =
        defaultSettings.rippleOpacity;
    widget.settings.rippleSettings.rippleColor = defaultSettings.rippleColor;
    widget.settings.rippleSettings.rippleDropCount =
        defaultSettings.rippleDropCount;
    widget.settings.rippleSettings.rippleOvalness =
        defaultSettings.rippleOvalness;
    widget.settings.rippleSettings.rippleRotation =
        defaultSettings.rippleRotation;
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
    if (presetData.containsKey('rippleIntensity')) {
      widget.settings.rippleSettings.rippleIntensity =
          presetData['rippleIntensity'];
    }
    if (presetData.containsKey('rippleSize')) {
      widget.settings.rippleSettings.rippleSize = presetData['rippleSize'];
    }
    if (presetData.containsKey('rippleSpeed')) {
      widget.settings.rippleSettings.rippleSpeed = presetData['rippleSpeed'];
    }
    if (presetData.containsKey('rippleOpacity')) {
      widget.settings.rippleSettings.rippleOpacity =
          presetData['rippleOpacity'];
    }
    if (presetData.containsKey('rippleColor')) {
      widget.settings.rippleSettings.rippleColor = presetData['rippleColor'];
    }
    if (presetData.containsKey('rippleDropCount')) {
      widget.settings.rippleSettings.rippleDropCount =
          presetData['rippleDropCount'];
    }
    if (presetData.containsKey('rippleOvalness')) {
      widget.settings.rippleSettings.rippleOvalness =
          presetData['rippleOvalness'];
    }
    if (presetData.containsKey('rippleRotation')) {
      widget.settings.rippleSettings.rippleRotation =
          presetData['rippleRotation'];
    }
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
      'rippleSize': widget.settings.rippleSettings.rippleSize,
      'rippleSpeed': widget.settings.rippleSettings.rippleSpeed,
      'rippleOpacity': widget.settings.rippleSettings.rippleOpacity,
      'rippleColor': widget.settings.rippleSettings.rippleColor,
      'rippleDropCount': widget.settings.rippleSettings.rippleDropCount,
      'rippleOvalness': widget.settings.rippleSettings.rippleOvalness,
      'rippleRotation': widget.settings.rippleSettings.rippleRotation,
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
