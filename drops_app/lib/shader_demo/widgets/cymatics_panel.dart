import 'package:flutter/material.dart';
import '../models/effect_settings.dart';
import '../models/cymatics_settings.dart';
import '../models/shader_effect.dart';
import '../controllers/effect_controller.dart';
import '../models/animation_options.dart';
import 'labeled_slider.dart';
import 'labeled_switch.dart';
import 'panel_header.dart';

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

  @override
  Widget build(BuildContext context) {
    final cymaticsSettings = widget.settings.cymaticsSettings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Panel header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Cymatics Controls',
            style: TextStyle(
              color: widget.sliderColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Target selection (apply to text/image)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apply To:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LabeledSwitch(
                      label: 'Image',
                      value: cymaticsSettings.applyToImage,
                      onChanged: (value) =>
                          _updateSettings((s) => s.applyToImage = value),
                    ),
                  ),
                  Expanded(
                    child: LabeledSwitch(
                      label: 'Text',
                      value: cymaticsSettings.applyToText,
                      onChanged: (value) =>
                          _updateSettings((s) => s.applyToText = value),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
