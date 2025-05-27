import 'package:flutter/material.dart';
import '../models/effect_settings.dart';
import '../models/cymatics_settings.dart';
import '../models/shader_effect.dart';
import '../controllers/effect_controller.dart';
import '../models/animation_options.dart';
import 'labeled_slider.dart';
import 'labeled_switch.dart';
import 'enhanced_panel_header.dart';
import '../models/presets_manager.dart';
import '../views/effect_controls.dart';

class CymaticsPanel extends StatefulWidget {
  final ShaderSettings settings;
  final Function(ShaderSettings) onSettingsChanged;
  final Color sliderColor;
  final BuildContext context;

  const CymaticsPanel({
    Key? key,
    required this.settings,
    required this.onSettingsChanged,
    required this.sliderColor,
    required this.context,
  }) : super(key: key);

  @override
  State<CymaticsPanel> createState() => _CymaticsPanelState();
}

class _CymaticsPanelState extends State<CymaticsPanel> {
  // Helper function to log events
  void _log(String message, {LogLevel level = LogLevel.info}) {
    EffectLogger.log('[CymaticsPanel] $message', level: level);
  }

  // Helper to update settings
  void _updateSettings(Function(CymaticsSettings) updateFunc) {
    // Create a deep copy of the current settings
    final updatedSettings = ShaderSettings.fromMap(widget.settings.toMap());

    // Capture the previous values for logging changes
    final prevSettings = updatedSettings.cymaticsSettings;
    final double prevIntensity = prevSettings.intensity;
    final double prevFrequency = prevSettings.frequency;
    final double prevAmplitude = prevSettings.amplitude;
    final double prevComplexity = prevSettings.complexity;
    final double prevSpeed = prevSettings.speed;
    final double prevColorIntensity = prevSettings.colorIntensity;
    final double prevAudioSensitivity = prevSettings.audioSensitivity;
    final bool prevCymaticsAnimated = prevSettings.cymaticsAnimated;
    final bool prevApplyToImage = prevSettings.applyToImage;
    final bool prevApplyToText = prevSettings.applyToText;
    final bool prevApplyToBackground = prevSettings.applyToBackground;

    // Debug current object references
    _log(
      "Before update - Original settings hash: ${widget.settings.hashCode}, Copy hash: ${updatedSettings.hashCode}",
    );

    // Apply the update to our copy
    updateFunc(updatedSettings.cymaticsSettings);

    // Enable cymatics if it's not already enabled (so changes are visible)
    if (!updatedSettings.cymaticsSettings.cymaticsEnabled) {
      updatedSettings.cymaticsSettings.cymaticsEnabled = true;
      _log("Auto-enabling cymatics effect to make changes visible");
    }

    // Log changes for debugging
    final newSettings = updatedSettings.cymaticsSettings;
    if (prevIntensity != newSettings.intensity) {
      _log(
        "Changed intensity: ${prevIntensity.toStringAsFixed(2)} → ${newSettings.intensity.toStringAsFixed(2)}",
      );
    }
    if (prevFrequency != newSettings.frequency) {
      _log(
        "Changed frequency: ${prevFrequency.toStringAsFixed(2)} → ${newSettings.frequency.toStringAsFixed(2)}",
      );
    }
    if (prevAmplitude != newSettings.amplitude) {
      _log(
        "Changed amplitude: ${prevAmplitude.toStringAsFixed(2)} → ${newSettings.amplitude.toStringAsFixed(2)}",
      );
    }
    if (prevComplexity != newSettings.complexity) {
      _log(
        "Changed complexity: ${prevComplexity.toStringAsFixed(2)} → ${newSettings.complexity.toStringAsFixed(2)}",
      );
    }
    if (prevSpeed != newSettings.speed) {
      _log(
        "Changed speed: ${prevSpeed.toStringAsFixed(2)} → ${newSettings.speed.toStringAsFixed(2)}",
      );
    }
    if (prevColorIntensity != newSettings.colorIntensity) {
      _log(
        "Changed color intensity: ${prevColorIntensity.toStringAsFixed(2)} → ${newSettings.colorIntensity.toStringAsFixed(2)}",
      );
    }
    if (prevAudioSensitivity != newSettings.audioSensitivity) {
      _log(
        "Changed audio sensitivity: ${prevAudioSensitivity.toStringAsFixed(2)} → ${newSettings.audioSensitivity.toStringAsFixed(2)}",
      );
    }
    if (prevCymaticsAnimated != newSettings.cymaticsAnimated) {
      _log(
        "Changed animation enabled: $prevCymaticsAnimated → ${newSettings.cymaticsAnimated}",
      );
    }
    if (prevApplyToImage != newSettings.applyToImage) {
      _log(
        "Changed apply to image: $prevApplyToImage → ${newSettings.applyToImage}",
      );
    }
    if (prevApplyToText != newSettings.applyToText) {
      _log(
        "Changed apply to text: $prevApplyToText → ${newSettings.applyToText}",
      );
    }
    if (prevApplyToBackground != newSettings.applyToBackground) {
      _log(
        "Changed apply to background: $prevApplyToBackground → ${newSettings.applyToBackground}",
      );
    }

    // SIMPLIFIED UPDATE MECHANISM
    // Directly update the settings instead of using a two-step process
    _log("Applying settings update directly");
    widget.onSettingsChanged(updatedSettings);
  }

  // Helper to handle Apply to Image changes
  void _handleApplyToImageChanged(bool value) {
    _log("Apply to Image checkbox clicked: $value");
    _updateSettings((s) {
      s.applyToImage = value;

      // If turning off apply to image, make sure background is enabled
      if (!value && !s.applyToBackground) {
        s.applyToBackground = true;
        _log(
          "Auto-enabling Apply to Background since Apply to Image was disabled",
        );
      }
    });
  }

  // Helper to handle Apply to Background changes
  void _handleApplyToBackgroundChanged(bool value) {
    _log("Apply to Background checkbox clicked: $value");
    _updateSettings((s) {
      s.applyToBackground = value;

      // If turning off apply to background, make sure image is enabled
      if (!value && !s.applyToImage) {
        s.applyToImage = true;
        _log(
          "Auto-enabling Apply to Image since Apply to Background was disabled",
        );
      }
    });
  }

  // Static methods for preset management
  static Map<ShaderAspect, Map<String, dynamic>> _cachedPresets = {};
  static int _refreshCounter = 0;

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

  void _resetCymatics() {
    final updatedSettings = ShaderSettings.fromMap(widget.settings.toMap());

    // Create a new CymaticsSettings instance with default values
    final defaultCymaticsSettings = CymaticsSettings(
      applyToImage: false, // Default to background only
      applyToText: false,
      applyToBackground: true,
    );

    // Update cymatics settings directly
    updatedSettings.cymaticsSettings.cymaticsEnabled = false;
    updatedSettings.cymaticsSettings.intensity =
        defaultCymaticsSettings.intensity;
    updatedSettings.cymaticsSettings.frequency =
        defaultCymaticsSettings.frequency;
    updatedSettings.cymaticsSettings.amplitude =
        defaultCymaticsSettings.amplitude;
    updatedSettings.cymaticsSettings.complexity =
        defaultCymaticsSettings.complexity;
    updatedSettings.cymaticsSettings.speed = defaultCymaticsSettings.speed;
    updatedSettings.cymaticsSettings.colorIntensity =
        defaultCymaticsSettings.colorIntensity;
    updatedSettings.cymaticsSettings.audioReactive =
        defaultCymaticsSettings.audioReactive;
    updatedSettings.cymaticsSettings.audioSensitivity =
        defaultCymaticsSettings.audioSensitivity;
    updatedSettings.cymaticsSettings.cymaticsAnimated =
        defaultCymaticsSettings.cymaticsAnimated;
    updatedSettings.cymaticsSettings.applyToImage =
        defaultCymaticsSettings.applyToImage;
    updatedSettings.cymaticsSettings.applyToText =
        defaultCymaticsSettings.applyToText;
    updatedSettings.cymaticsSettings.applyToBackground =
        defaultCymaticsSettings.applyToBackground;

    widget.onSettingsChanged(updatedSettings);
  }

  void _applyCymaticsPreset(Map<String, dynamic> presetData) {
    final updatedSettings = ShaderSettings.fromMap(widget.settings.toMap());

    if (presetData.containsKey('cymaticsSettings') &&
        presetData['cymaticsSettings'] is Map<String, dynamic>) {
      final cymaticsMap =
          presetData['cymaticsSettings'] as Map<String, dynamic>;

      // Create a new CymaticsSettings from the map
      final updatedCymaticsSettings = CymaticsSettings.fromMap(cymaticsMap);

      // Copy individual properties instead of trying to assign the whole object
      updatedSettings.cymaticsSettings.cymaticsEnabled =
          updatedCymaticsSettings.cymaticsEnabled;
      updatedSettings.cymaticsSettings.intensity =
          updatedCymaticsSettings.intensity;
      updatedSettings.cymaticsSettings.frequency =
          updatedCymaticsSettings.frequency;
      updatedSettings.cymaticsSettings.amplitude =
          updatedCymaticsSettings.amplitude;
      updatedSettings.cymaticsSettings.complexity =
          updatedCymaticsSettings.complexity;
      updatedSettings.cymaticsSettings.speed = updatedCymaticsSettings.speed;
      updatedSettings.cymaticsSettings.colorIntensity =
          updatedCymaticsSettings.colorIntensity;
      updatedSettings.cymaticsSettings.audioReactive =
          updatedCymaticsSettings.audioReactive;
      updatedSettings.cymaticsSettings.audioSensitivity =
          updatedCymaticsSettings.audioSensitivity;
      updatedSettings.cymaticsSettings.cymaticsAnimated =
          updatedCymaticsSettings.cymaticsAnimated;
      updatedSettings.cymaticsSettings.applyToImage =
          updatedCymaticsSettings.applyToImage;
      updatedSettings.cymaticsSettings.applyToText =
          updatedCymaticsSettings.applyToText;
      updatedSettings.cymaticsSettings.applyToBackground =
          updatedCymaticsSettings.applyToBackground;

      widget.onSettingsChanged(updatedSettings);
      return;
    }

    widget.onSettingsChanged(updatedSettings);
  }

  Future<void> _saveCymaticsPreset(ShaderAspect aspect, String name) async {
    final cymaticsSettings = widget.settings.cymaticsSettings;

    Map<String, dynamic> presetData = {
      'cymaticsSettings': cymaticsSettings.toMap(),
    };

    bool success = await PresetsManager.savePreset(aspect, name, presetData);

    if (success) {
      _cachedPresets[aspect] = await PresetsManager.getPresetsForAspect(aspect);
      _refreshPresets();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cymaticsSettings = widget.settings.cymaticsSettings;

    // Log current settings state when the panel is rebuilt
    _log(
      "CymaticsPanel.build: settings hash=${widget.settings.hashCode}, " +
          "intensity=${cymaticsSettings.intensity.toStringAsFixed(2)}, " +
          "frequency=${cymaticsSettings.frequency.toStringAsFixed(2)}, " +
          "amplitude=${cymaticsSettings.amplitude.toStringAsFixed(2)}, " +
          "speed=${cymaticsSettings.speed.toStringAsFixed(2)}, " +
          "applyToImage=${cymaticsSettings.applyToImage}, " +
          "applyToBackground=${cymaticsSettings.applyToBackground}",
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced panel header
        EnhancedPanelHeader(
          aspect: ShaderAspect.cymatics,
          onPresetSelected: _applyCymaticsPreset,
          onReset: _resetCymatics,
          onSavePreset: _saveCymaticsPreset,
          sliderColor: widget.sliderColor,
          loadPresets: _loadPresetsForAspect,
          deletePreset: _deletePresetAndUpdate,
          refreshPresets: _refreshPresets,
          refreshCounter: _refreshCounter,
          applyToImage: cymaticsSettings.applyToImage,
          applyToText: cymaticsSettings.applyToText,
          applyToBackground: cymaticsSettings.applyToBackground,
          onApplyToImageChanged: _handleApplyToImageChanged,
          onApplyToTextChanged: (value) =>
              _updateSettings((s) => s.applyToText = value),
          onApplyToBackgroundChanged: _handleApplyToBackgroundChanged,
        ),

        const SizedBox(height: 16),

        // Audio sensitivity slider (always shown now)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LabeledSlider(
            label: 'Audio Sensitivity',
            value: cymaticsSettings.audioSensitivity,
            min: 0.0,
            max: 1.0,
            divisions: 20,
            displayValue:
                '${(cymaticsSettings.audioSensitivity * 100).round()}%',
            activeColor: widget.sliderColor,
            onChanged: (value) =>
                _updateSettings((s) => s.audioSensitivity = value),
          ),
        ),

        const SizedBox(height: 16),

        // Main effect parameters
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              // Intensity slider
              LabeledSlider(
                label: 'Intensity',
                value: cymaticsSettings.intensity,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                displayValue: '${(cymaticsSettings.intensity * 100).round()}%',
                activeColor: widget.sliderColor,
                onChanged: (value) =>
                    _updateSettings((s) => s.intensity = value),
              ),

              // Frequency slider
              LabeledSlider(
                label: 'Frequency',
                value: cymaticsSettings.frequency,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                displayValue: '${(cymaticsSettings.frequency * 100).round()}%',
                activeColor: widget.sliderColor,
                onChanged: (value) =>
                    _updateSettings((s) => s.frequency = value),
              ),

              // Amplitude slider
              LabeledSlider(
                label: 'Amplitude',
                value: cymaticsSettings.amplitude,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                displayValue: '${(cymaticsSettings.amplitude * 100).round()}%',
                activeColor: widget.sliderColor,
                onChanged: (value) =>
                    _updateSettings((s) => s.amplitude = value),
              ),

              // Complexity slider
              LabeledSlider(
                label: 'Complexity',
                value: cymaticsSettings.complexity,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                displayValue: '${(cymaticsSettings.complexity * 100).round()}%',
                activeColor: widget.sliderColor,
                onChanged: (value) =>
                    _updateSettings((s) => s.complexity = value),
              ),

              // Speed slider
              LabeledSlider(
                label: 'Speed',
                value: cymaticsSettings.speed,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                displayValue: '${(cymaticsSettings.speed * 100).round()}%',
                activeColor: widget.sliderColor,
                onChanged: (value) => _updateSettings((s) => s.speed = value),
              ),

              // Color influence slider
              LabeledSlider(
                label: 'Color Intensity',
                value: cymaticsSettings.colorIntensity,
                min: 0.0,
                max: 1.0,
                divisions: 20,
                displayValue:
                    '${(cymaticsSettings.colorIntensity * 100).round()}%',
                activeColor: widget.sliderColor,
                onChanged: (value) =>
                    _updateSettings((s) => s.colorIntensity = value),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Animation controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Animation',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              LabeledSwitch(
                label: 'Animate Effect',
                value: cymaticsSettings.cymaticsAnimated,
                onChanged: (value) =>
                    _updateSettings((s) => s.cymaticsAnimated = value),
              ),

              // Animation settings (only shown when animation is enabled)
              if (cymaticsSettings.cymaticsAnimated) ...[
                const SizedBox(height: 8),
                LabeledSlider(
                  label: 'Animation Speed',
                  value: cymaticsSettings.animOptions.speed,
                  min: 0.1,
                  max: 5.0,
                  divisions: 49,
                  displayValue:
                      '${cymaticsSettings.animOptions.speed.toStringAsFixed(1)}x',
                  activeColor: widget.sliderColor,
                  onChanged: (value) {
                    _updateSettings((s) {
                      final animOptions = s.animOptions;
                      animOptions.speed = value;
                      s.animOptions = animOptions;
                    });
                  },
                ),
                LabeledSlider(
                  label: 'Animation Mode',
                  value: cymaticsSettings.animOptions.mode.index.toDouble(),
                  min: 0,
                  max: 1,
                  divisions: 1,
                  displayValue: cymaticsSettings.animOptions.mode == 0
                      ? 'Pulse'
                      : 'Random',
                  activeColor: widget.sliderColor,
                  onChanged: (value) {
                    _updateSettings((s) {
                      final animOptions = s.animOptions;
                      animOptions.mode = value.round() == 0
                          ? AnimationMode.pulse
                          : AnimationMode.randomixed;
                      s.animOptions = animOptions;
                    });
                  },
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Effect description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Cymatics visualizes sound waves as patterns. It automatically reacts to music playback.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ),
      ],
    );
  }
}
