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
    final updatedSettings = ShaderSettings.fromMap(widget.settings.toMap());
    updateFunc(updatedSettings.cymaticsSettings);
    widget.onSettingsChanged(updatedSettings);
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
      applyToImage: true,
      applyToText: false,
    );

    // Use the constructor to update settings properly
    final fixedSettings = ShaderSettings(
      colorSettings: updatedSettings.colorSettings,
      blurSettings: updatedSettings.blurSettings,
      noiseSettings: updatedSettings.noiseSettings,
      textfxSettings: updatedSettings.textfxSettings,
      textLayoutSettings: updatedSettings.textLayoutSettings,
      rainSettings: updatedSettings.rainSettings,
      chromaticSettings: updatedSettings.chromaticSettings,
      rippleSettings: updatedSettings.rippleSettings,
      musicSettings: updatedSettings.musicSettings,
      cymaticsSettings: defaultCymaticsSettings,
    );

    widget.onSettingsChanged(fixedSettings);
  }

  void _applyCymaticsPreset(Map<String, dynamic> presetData) {
    final updatedSettings = ShaderSettings.fromMap(widget.settings.toMap());

    if (presetData.containsKey('cymaticsSettings') &&
        presetData['cymaticsSettings'] is Map<String, dynamic>) {
      final cymaticsMap =
          presetData['cymaticsSettings'] as Map<String, dynamic>;

      // Create a new CymaticsSettings from the map
      final updatedCymaticsSettings = CymaticsSettings.fromMap(cymaticsMap);

      // Create a new ShaderSettings with the updated cymatics settings
      final fixedSettings = ShaderSettings(
        colorSettings: updatedSettings.colorSettings,
        blurSettings: updatedSettings.blurSettings,
        noiseSettings: updatedSettings.noiseSettings,
        textfxSettings: updatedSettings.textfxSettings,
        textLayoutSettings: updatedSettings.textLayoutSettings,
        rainSettings: updatedSettings.rainSettings,
        chromaticSettings: updatedSettings.chromaticSettings,
        rippleSettings: updatedSettings.rippleSettings,
        musicSettings: updatedSettings.musicSettings,
        cymaticsSettings: updatedCymaticsSettings,
      );

      widget.onSettingsChanged(fixedSettings);
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
          onApplyToImageChanged: (value) =>
              _updateSettings((s) => s.applyToImage = value),
          onApplyToTextChanged: (value) =>
              _updateSettings((s) => s.applyToText = value),
        ),

        const SizedBox(height: 16),

        // Audio reactivity toggle
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: LabeledSwitch(
            label: 'React to Audio',
            value: cymaticsSettings.audioReactive,
            onChanged: (value) =>
                _updateSettings((s) => s.audioReactive = value),
          ),
        ),

        const SizedBox(height: 8),

        // Audio sensitivity slider (only shown when audioReactive is true)
        if (cymaticsSettings.audioReactive)
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
            'Cymatics visualizes sound waves as patterns. It reacts to music when audio reactive mode is enabled.',
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
